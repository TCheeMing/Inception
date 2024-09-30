# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cteoh <cteoh@student.42kl.edu.my>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/09/27 14:55:26 by cteoh             #+#    #+#              #
#    Updated: 2024/09/30 10:16:08 by cteoh            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Program Name
NAME = Inception

# Source and Object Files
SRCDIR			= srcs
NGINX			= Dockerfile.nginx nginx.conf
WORDPRESS		= Dockerfile.wordpress-php
SRC				= docker-compose.yml $(NGINX) $(WORDPRESS)
SECRETS			= server.rsa.crt server.rsa.key
WORDPRESS_DIR	= ~/data/wordpress
vpath % $(shell find $(SRCDIR) -type d -print | tr "\n" ":"					  \
		| awk '{print substr ($$1, 1, length($$1) - 1)}')
vpath % secrets

# Headers

# Dependencies (Tools)
SSL_GEN	= ssl-cert-gen.sh
WP_GEN	= wordpress-gen.sh

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

$(NAME): $(SECRETS) $(WORDPRESS_DIR) $(SRC)
	@printf "$(GREEN)Generating and starting containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose up --build -d
	@echo "#!/bin/sh" > $(NAME)
	@echo >> $(NAME)
	@echo "cd $(SRCDIR) && docker compose logs -f" >> $(NAME)
	@chmod 755 $(NAME)
	@sleep 2 && docker ps -a

$(SECRETS) &:
	@printf "$(GREEN)Generating SSL certificates...$(RESET)\n"
	@mkdir -p secrets/
	@./$(SRCDIR)/requirements/nginx/tools/$(SSL_GEN)

$(WORDPRESS_DIR):
	@printf "$(GREEN)Downloading WordPress files...$(RESET)\n"
	@mkdir -p ~/data
	@./$(SRCDIR)/requirements/wordpress/tools/$(WP_GEN)

up:
	@printf "$(GREEN)Starting containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose up -d
	@sleep 2 && docker ps -a

clean:
	@printf "$(YELLOW)Stopping and removing all containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose down

fclean: clean
	@printf "$(YELLOW)Removing all secrets...$(RESET)\n"
	@$(RM) secrets/*
	@printf "$(YELLOW)Removing all bind mounts...$(RESET)\n"
	@$(RM) ~/data
	@printf "$(YELLOW)Removing all images...$(RESET)\n"
	@$(shell docker rmi -f $$(docker images -q) > /dev/null 2>&1)
	@printf "$(YELLOW)Removing all anonymous volumes, unused networks, and unused build cache...$(RESET)\n"
	@docker system prune --volumes -f
	@$(RM) $(NAME)

re: fclean all

.PHONY: all clean fclean re up