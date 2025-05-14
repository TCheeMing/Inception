# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cteoh <cteoh@student.42kl.edu.my>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/09/27 14:55:26 by cteoh             #+#    #+#              #
#    Updated: 2025/05/14 02:13:17 by cteoh            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Program Name
NAME = Inception

# Source and Object Files
SRCDIR			= srcs
ENV				= .env
PHP				= php-fpm.conf www.conf
MARIADB			= mariadb.Dockerfile mariadb-server.cnf mariadb-run.sh
NGINX			= nginx.Dockerfile nginx.conf
WORDPRESS		= wordpress-php.Dockerfile wordpress-run.sh
ADMINER			= adminer.Dockerfile
FTP				= ftp.Dockerfile ftp-run.sh
REDIS			= redis.Dockerfile redis.conf
RSYSLOG			= rsyslog.Dockerfile rsyslog.conf
GITEA			= gitea.Dockerfile app.ini gitea-run.sh
BONUS			= $(ADMINER) $(FTP) $(GITEA) $(REDIS) $(RSYSLOG)
SRC				= docker-compose.yml .env $(MARIADB) $(NGINX) $(WORDPRESS)	  \
				  $(BONUS) $(PHP)

DATADIR			= ~/data

SECRETSDIR				= secrets
NGINX_SECRETS			= $(NGINX_CERT) $(NGINX_KEY)
NGINX_CERT				= nginx-server.rsa.crt
NGINX_KEY				= nginx-server.rsa.key

MARIADB_SECRETS			= $(MARIADB_ROOT_PASS) $(MARIADB_USER_PASS)
MARIADB_ROOT_PASS		= mariadb_root_password
MARIADB_USER_PASS		= mariadb_password

WORDPRESS_SECRETS		= $(WORDPRESS_ADMIN_PASS) $(WORDPRESS_USER_PASS)
WORDPRESS_ADMIN_PASS	= wordpress_admin_password
WORDPRESS_USER_PASS		= wordpress_user_password

GITEA_SECRETS			= $(GITEA_CERT) $(GITEA_KEY)
GITEA_CERT				= gitea-server.rsa.crt
GITEA_KEY				= gitea-server.rsa.key

FTP_SECRET				= ftp_password
SECRETS					= $(SECRETSDIR) $(NGINX_SECRETS) $(MARIADB_SECRETS)	  \
						  $(WORDPRESS_SECRETS) $(GITEA_SECRETS) $(FTP_SECRET)
vpath % $(shell find $(SRCDIR) -type d -print | tr "\n" ":"					  \
		| awk '{print substr ($$1, 1, length($$1) - 1)}'):$(SECRETSDIR)

# Other Commands and Flags
RM			= rm -rf
MAKEFLAGS	= --no-print-directory

# Misc
RED		= \e[0;31m
GREEN	= \e[0;32m
YELLOW	= \e[0;33m
RESET	= \e[0m

all: $(NAME)

$(NAME): $(DATADIR) $(SECRETS) $(SRC)
	@printf "$(GREEN)Building and starting containers...$(RESET)\n"
	@chmod -R 644 $(SECRETSDIR)/*
	@cd $(SRCDIR) && docker compose up --build --detach
	@echo "#!/bin/sh" > $(NAME)
	@echo >> $(NAME)
	@echo "cd $(SRCDIR) && docker compose logs --follow" >> $(NAME)
	@chmod 755 $(NAME)
	@docker ps --all

$(NGINX_CERT):
	@printf "$(RED)Please place your NGINX cert in file named '$(NGINX_CERT)' in the directory '$(SECRETSDIR)'.$(RESET)\n"
	@exit 1

$(NGINX_KEY):
	@printf "$(RED)Please place your NGINX key in file named '$(NGINX_KEY)' in the directory '$(SECRETSDIR)'.$(RESET)\n"
	@exit 1

$(MARIADB_ROOT_PASS):
	@printf "$(RED)Please place your MariaDB root password in file named '$(MARIADB_ROOT_PASS)' in the directory '$(SECRETSDIR)'.$(RESET)\n"
	@exit 1

$(MARIADB_USER_PASS):
	@printf "$(RED)Please place your MariaDB user password in file named '$(MARIADB_USER_PASS)' in the directory '$(SECRETSDIR)'.$(RESET)\n"
	@exit 1

$(WORDPRESS_ADMIN_PASS):
	@printf "$(RED)Please place your WordPress admin password in file '$(WORDPRESS_ADMIN_PASS)' in the directory '$(SECRETSDIR)'.$(RESET)\n"
	@exit 1

$(WORDPRESS_USER_PASS):
	@printf "$(RED)Please place your WordPress user password in file '$(WORDPRESS_USER_PASS)' in the directory '$(SECRETSDIR)'.$(RESET)\n"
	@exit 1

$(FTP_SECRET):
	@printf "$(RED)Please place your FTP user password in file named '$(FTP_SECRET)' in the directory '$(SECRETSDIR)'.$(RESET)\n"
	@exit 1

$(GITEA_CERT):
	@printf "$(RED)Please place your Gitea cert in file named '$(GITEA_CERT)' in the directory '$(SECRETSDIR)'.$(RESET)\n"
	@exit 1

$(GITEA_KEY):
	@printf "$(RED)Please place your Gitea key in file named '$(GITEA_KEY)' in the directory '$(SECRETSDIR)'.$(RESET)\n"
	@exit 1

$(SECRETSDIR):
	@mkdir --parents $(SECRETSDIR)

$(DATADIR):
	@mkdir --parents $(DATADIR)

up:
	@printf "$(GREEN)Starting containers...$(RESET)\n"
	@chmod -R 644 $(SECRETSDIR)/*
	@cd $(SRCDIR) && docker compose up --detach
	@echo "#!/bin/sh" > $(NAME)
	@echo >> $(NAME)
	@echo "cd $(SRCDIR) && docker compose logs --follow" >> $(NAME)
	@chmod 755 $(NAME)
	@docker ps --all

stop:
	@printf "$(GREEN)Stopping containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose stop
	@$(RM) $(NAME)
	@docker ps --all

clean:
	@printf "$(YELLOW)Stopping and removing all containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose down
	@$(RM) $(NAME)

fclean: clean
	@printf "$(YELLOW)Removing all unused volumes...$(RESET)\n"
	@docker volume prune --all --force
	@printf "$(YELLOW)Removing all unused networks, unused images and build cache...$(RESET)\n"
	@docker system prune --all --force

re: fclean all

.PHONY: all clean fclean re up
