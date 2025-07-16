# Utilisation de l'image PHP 8.3 avec Apache
FROM php:8.3-apache

# Permettre à Composer d'être exécuté en tant que superutilisateur
ENV COMPOSER_ALLOW_SUPERUSER=1

# Installation des dépendances nécessaires
RUN apt-get update \
    && apt-get install -yqq --no-install-recommends \
       git \
       curl \
       libpq-dev \
       libicu-dev \
       zip \
       unzip \
       postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configuration et installation des extensions PHP requises
RUN docker-php-ext-configure intl && docker-php-ext-install pdo pdo_pgsql intl

# Installation de Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Définir le répertoire de travail
WORKDIR /var/www/safebase

# Copier tout le projet (y compris les fichiers de configuration)
COPY . .

# Installation des dépendances via Composer
RUN composer install --no-interaction --no-progress --prefer-dist

# Copier le fichier de configuration Apache
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Assurer que les permissions sont correctes
RUN chown -R www-data:www-data /var/www/safebase

# Passer à l'utilisateur www-data pour exécuter Apache
USER www-data

# Exposer le port 80 pour accéder à l'application
EXPOSE 80

# Commande par défaut pour démarrer Apache en mode avant-plan
CMD ["apache2-foreground"]
