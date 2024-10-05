# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cteoh <cteoh@student.42kl.edu.my>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/09/27 14:55:26 by cteoh             #+#    #+#              #
#    Updated: 2024/10/06 03:11:17 by cteoh            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Program Name
NAME = Inception

# Source and Object Files
SRCDIR			= srcs
MARIADB			= mariadb.Dockerfile
WORDPRESS		= wordpress-php.Dockerfile
NGINX			= nginx.Dockerfile nginx.conf
SRC				= docker-compose.yml $(MARIADB) $(WORDPRESS) $(NGINX)
SSL_CERTS		= server.rsa.crt server.rsa.key
MARIADB_PASS	= mariadb_root_password.txt mariadb_password.txt
vpath % $(shell find $(SRCDIR) -type d -print | tr "\n" ":"					  \
		| awk '{print substr ($$1, 1, length($$1) - 1)}')
vpath % secrets

# Headers

# Dependencies (Tools)
MARIADB_GEN	= mariadb-password-gen.sh
SSL_GEN		= ssl-cert-gen.sh

# Libraries

# Other Commands and Flags
RM			= rm -rf
MAKEFLAGS	= --no-print-directory

# Misc
RED		= \e[0;31m
GREEN	= \e[0;32m
YELLOW	= \e[0;33m
RESET	= \e[0m

all: $(NAME)

$(NAME): $(MARIADB_PASS) $(SSL_CERTS) $(SRC)
	@printf "$(GREEN)Generating and starting containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose up --build -d
	@echo "#!/bin/sh" > $(NAME)
	@echo >> $(NAME)
	@echo "cd $(SRCDIR) && docker compose logs -f" >> $(NAME)
	@chmod 755 $(NAME)
	@sleep 5 && docker ps -a

$(MARIADB_PASS) &:
	@printf "$(GREEN)Generating MariaDB passwords...$(RESET)\n"
	@mkdir -p secrets/
	@./$(SRCDIR)/requirements/mariadb/tools/$(MARIADB_GEN)

$(SSL_CERTS) &:
	@printf "$(GREEN)Generating SSL certificates...$(RESET)\n"
	@mkdir -p secrets/
	@./$(SRCDIR)/requirements/nginx/tools/$(SSL_GEN)

up:
	@printf "$(GREEN)Starting containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose up -d
	@sleep 5 && docker ps -a

stop:
	@printf "$(GREEN)Stopping containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose stop
	@sleep 5 && docker ps -a

clean:
	@printf "$(YELLOW)Stopping and removing all containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose down

fclean: clean
	@printf "$(YELLOW)Removing all secrets...$(RESET)\n"
	@$(RM) secrets/*
	@printf "$(YELLOW)Removing all named volumes...$(RESET)\n"
	@$(shell docker volume rm -f $$(docker volume ls -q) > /dev/null 2>&1)
	@printf "$(YELLOW)Removing all images...$(RESET)\n"
	@$(shell docker rmi -f $$(docker images -q) > /dev/null 2>&1)
	@printf "$(YELLOW)Removing all anonymous volumes, unused networks, and unused build cache...$(RESET)\n"
	@docker system prune --volumes -f
	@$(RM) $(NAME)

re: fclean all

.PHONY: all clean fclean re up