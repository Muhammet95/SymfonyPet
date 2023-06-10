FROM php:7.4-fpm

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions gd xdebug

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    zip \
    unzip \
    libonig-dev \
    zlib1g-dev \
    libpng-dev \
    wget

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

# Install PHP extensions
RUN install-php-extensions pdo pdo_pgsql exif pcntl bcmath gd soap zip
#RUN docker-php-ext-install pdo_mysql exif pcntl bcmath gd soap zip

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
#RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
        chown -R $user:$user /home/$user

# Install Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash \
    && sudo mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

RUN git config --global user.email "go.suits.3@gmail.com" && git config --global user.name "Muhammet95"

# Set working directory
WORKDIR /var/www

USER $user