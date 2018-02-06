# Présentation

L'API inferenstar permet de protéger les plateformes web et leurs utilisateurs contre le vol de leurs données personnelles et l'accès frauduleux à leurs comptes.

Elle analyse en temps réel les événements de sécurité de la plateforme qui utilise l'API. Pour chaque événement de sécurité notre API renvoie un score de confiance afin d'indiquer si celui-ci est "Acceptable", "Suspicieux" ou "Frauduleux". Les réponses comportent aussi d'autres métadonnées comme la géolocalisations, le type de dispositif utilisé, si celui-ci est vulnérable, si l'utilisateur utilise le dark web ou exploite une IP malicieuse, etc.

La plateforme cliente peut alors prendre les mesures nécessaires pour contenir le risque utilisateur en alertant celui-ci (par email ou SMS) ou en bloquant temporairement le compte utilisateur usurpé.

# Techniquement

L'API inferenstar reçoit des événement sous forme de requêtes HTTP/POST, les traite de manière asynchrone puis informe la plateforme web cliente du niveau de menace. La réponse se réalise généralement entre une 1s à 2s.

## Concrètement

La plateforme cliente envoie sur https://events.inferenstar.com une requête HTTP/POST/JSON décrivant l'événement de sécurité. Notre API est conçue pour tenir la charge - plusieurs centaines de requêtes par seconde.

Exemple de requête de demande d'analyse de sécurité:
```json
{
  "type": "login_successful",
  "uref": "1234567",
  "email": "awesome.customer@gmail.com",
  "remote_ip": "xxx.xxx.xxx.xxx",
  "callback_url": "http://www.my-awesome-website.com/inferenstar-callbacks",
  "http_headers": {
    "User-Agent": "...",
    "...": "..." # Tous les en-tête HTTP de la requête du client sur la plateforme.
  }
}
```
La réponse HTTP à cette requête est une "202 Accepted". Une à deux secondes après ceci notre API envoie une requête HTTP/POST/JSON sur l'URL de callback précisée lors de la demande d'analyse de sécurité.

Exemple de réponse asynchrone:
```json
{
  "created_at": "...",
  "uref": "1234567",
  "proxy_detected": false,
  "dark_web_detected": false,
  "location": {
    "country": "France",
    "country_code": "FR",
    "city": "Bordeaux"
  },
  "device": {
    "os": "Windows 8",
    "software": "IE",
    "type": "computer"
  },
  "risk": {
    "label": "SUSPICIOUS",
    "score": 0.53,
    "messages": [
      {
        "code": 100,
        "new_country": "France"
      }
    ]
  }
}
```

## Requête de demande d'analyse de sécurité

Lorsqu'un utilisateur réalise sur la plateforme cliente certains types d'actions comme "créer un compte", "tenter s'authentifier", "demander à changer son mot de passe", "accéder à des informations sensibles" (ou autre), il faut informer notre API au moyen d'une requête HTTP/POST. Celui-ci doit posséder plusieurs attributs.

### Attribut `type`:
L'attribut `type` peut prendre une valeur parmi ceux-ci:
`sign_up_successful`, indique à notre API qu'un compte utilisateur a été créé avec succès.
`sign_up_failed`, échec lors de la creation d'un compte utilisateur. Ceci permet de commencer à rassembler des faiseaux d'informations sur des potentiels robots.
`login_successful`, un utilisateur s'est identifié avec succès sur la plateforme cliente.
`login_failed`, un utilisateur a tenté de s'identifier sur la plateforme mais ceci n'a pas fonctionné (mauvais identifiant ou mot de passe par exemple).
`logout_successful`, l'utilisateur s'est déconnecté avec succès.
`reset_pwd_req`, un utilisateur a réalisé une demander de réinitialisation de son mot de passe.
`reset_pwd_successful`, un utilisateur a modifié avec succès son mot de passe.
`reset_pwd_failed`, un utilisateur a tenté de motifié son mot de passe mais ceci n'a pas fonctionné.
`profile_updated`, un utilisateur a modifié ses informations personnelles.

### Attribut `uref`:

L'attribut `uref` est une chaine de caractère permettant de désigner de manière unique un utilisateur au sein de la plateforme. Il peut s'agir de l'ID en base de données, de son UUID, de son email, du SHA1 d'une de ces informations. Il peut aussi s'agir d'un UUID spécifiquement créé pour la communication avec inferenstar.

### Attribut `email`:

L'attribut `email` représente l'email utilisée par l'utilisateur au sein de la plateforme. Cette information est importante pour l'analyse de sécurité car nous exploitons plusieurs points de contrôle notamment pour détecter si l'adresse email n'a pas fait l'objet d'une fuite de données passées (ou à venir), si le domaine de l'adresse est fiable et/ou n'appartient à des `zones zombies`, etc.

### Attribut `remote_api`:

L'attribut `remote_ip` correspond à l'IP utilisée par l'utilisateur au moment de l'événement. Cette information est essentielle dans notre analyse de sécurité. Nous faisons beaucoup de contrôle sur cette information. Localisation, zones de confiance, si l'IP appartient au darkweb, etc.

### Attribut `http_headers`:

L'attribut `http_headers` représente l'ensemble des entêtes HTTP de la requête utilisateur sur la plateforme cliente. Ces données sont importantes pour l'analyse de sécurité. Nous recherchons dans celles-ci plusieurs schémas et faisceaux d'attaques. Notamment permettant détecter l'usage de VPN, Proxy fiables ou non, le type d'appareil utilisé, leurs obsolescences, des entête particuliers, etc.

### Attribut `callback_url`:

L'attribut `callback_url` précise l'URL devant recevoir nos réponses d'analyse de sécurité. Lorsque nous recevons un événement de sécurité, son analyse prend généralement entre 500ms et 2s suivant la volumétrie des données. Nous informons donc la plateforme cliente de l'analyse de cet événement de sécurité en envoyant une requête POST sur l'URL spécifiée par un callback.

## Authentification sur notre API

Pour authentifier la plateforme cliente, la requête cliente POST doit posséder l'entête HTTP suivant :
X-API-Key: xxxxxxxxxxxxxxxxxxxxxxxx. En cas d'erreur, une erreur 400 sera renvoyée.

### Utiliser l'API avec `curl`

#### Dans un terminal:
```
$ export X_API_KEY='...'
$ curl -i -X POST  -H "X-API-Key: $X_API_KEY" -d @./create_event.json 'https://events.inferenstar.com/'
```
#### Le fichier `create_event.json` minimal:
```json
{
  "type": "login_successful",
  "uref": "1234567",
  "email": "awesome.customer@gmail.com",
  "remote_ip": "xxx.xxx.xxx.xxx",
  "callback_url": "http://xxxxx.ngrok.io",
  "http_headers": {
    "User-Agent": "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)"
  }
}
```

