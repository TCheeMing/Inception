# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cteoh <cteoh@student.42kl.edu.my>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/09/27 14:55:26 by cteoh             #+#    #+#              #
#    Updated: 2025/05/11 12:00:51 by cteoh            ###   ########.fr        #
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
SECRETSDIR		= secrets
NGINX_SSL_CERTS	= nginx-server.rsa.crt nginx-server.rsa.key
GITEA_SSL_CERTS = gitea-server.rsa.crt gitea-server.rsa.key
MARIADB_PASS	= mariadb_root_password mariadb_password
WORDPRESS_PASS	= wordpress_admin_password wordpress_user_one_password
FTP_PASS		= ftp_password
SSH_KEY			= ssh_key ssh_key.pub
vpath % $(shell find $(SRCDIR) -type d -print | tr "\n" ":"					  \
		| awk '{print substr ($$1, 1, length($$1) - 1)}'):$(SECRETSDIR)

# Dependencies (Tools)
SECRETS_GEN	= $(SRCDIR)/requirements/tools/secrets-gen.sh

# Other Commands and Flags
RM			= rm -rf
MAKEFLAGS	= --no-print-directory

# Misc
RED		= \e[0;31m
GREEN	= \e[0;32m
YELLOW	= \e[0;33m
RESET	= \e[0m

all: $(NAME)

$(NAME): $(SECRETSDIR) $(MARIADB_PASS) $(WORDPRESS_PASS) $(FTP_PASS) $(NGINX_SSL_CERTS)		  \
		 $(GITEA_SSL_CERTS) $(SSH_KEY) $(SRC)
	@printf "$(GREEN)Generating and starting containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose up --build --detach
	@echo "#!/bin/sh" > $(NAME)
	@echo >> $(NAME)
	@echo "cd $(SRCDIR) && docker compose logs --follow" >> $(NAME)
	@chmod 755 $(NAME)
	@sleep 5 && docker ps --all

$(MARIADB_PASS) &:
	@printf "$(GREEN)Generating MariaDB passwords...$(RESET)\n"
	@./$(SECRETS_GEN) mariadb

$(WORDPRESS_PASS) &:
	@printf "$(GREEN)Generating WordPress passwords...$(RESET)\n"
	@./$(SECRETS_GEN) wordpress

$(FTP_PASS):
	@printf "$(GREEN)Generating FTP password...$(RESET)\n"
	@./$(SECRETS_GEN) ftp

$(NGINX_SSL_CERTS) &:
	@printf "$(GREEN)Generating NGINX SSL certificates...$(RESET)\n"
	@./$(SECRETS_GEN) nginx 2> /dev/null

$(SSH_KEY) &:
	@printf "$(GREEN)Generating SSH key...$(RESET)\n"
	@./$(SECRETS_GEN) ssh

$(GITEA_SSL_CERTS) &:
	@printf "$(GREEN)Generating Gitea SSL certificates...$(RESET)\n"
	@./$(SECRETS_GEN) gitea 2> /dev/null
	@chmod 604 $(SECRETSDIR)/gitea-server.rsa.key

$(SECRETSDIR):
	@mkdir --parents $(SECRETSDIR)

up:
	@printf "$(GREEN)Starting containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose up --detach
	@echo "#!/bin/sh" > $(NAME)
	@echo >> $(NAME)
	@echo "cd $(SRCDIR) && docker compose logs --follow" >> $(NAME)
	@chmod 755 $(NAME)
	@sleep 5 && docker ps --all

stop:
	@printf "$(GREEN)Stopping containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose stop
	@$(RM) $(NAME)
	@sleep 5 && docker ps --all

clean:
	@printf "$(YELLOW)Stopping and removing all containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose down
	@$(RM) $(NAME)

fclean: clean
	@printf "$(YELLOW)Removing all secrets...$(RESET)\n"
	@$(RM) $(SECRETSDIR)
	@printf "$(YELLOW)Removing all unused volumes...$(RESET)\n"
	@docker volume prune --all --force
	@printf "$(YELLOW)Removing all unused networks, unused images and build cache...$(RESET)\n"
	@docker system prune --all --force

re: fclean all

.PHONY: all clean fclean re up
