# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cteoh <cteoh@student.42kl.edu.my>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/09/27 14:55:26 by cteoh             #+#    #+#              #
#    Updated: 2024/10/09 16:49:06 by cteoh            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Program Name
NAME = Inception

# Source and Object Files
SRCDIR			= srcs
ENV				= .env
FTP				= ftp.Dockerfile sshd_config ftp-run.sh
MARIADB			= mariadb.Dockerfile mariadb-run.sh
NGINX			= nginx.Dockerfile nginx.conf
REDIS			= redis.Dockerfile redis.conf
WORDPRESS		= wordpress-php.Dockerfile wp-config.php wordpress-run.sh
SRC				= docker-compose.yml .env $(FTP) $(MARIADB) $(NGINX) $(REDIS) \
				  $(WORDPRESS)
SECRETSDIR		= secrets
SSL_CERTS		= server.rsa.crt server.rsa.key
MARIADB_PASS	= mariadb_root_password mariadb_password
FTP_PASS		= ftp_password
SSH_KEY			= ssh_key
vpath % $(shell find $(SRCDIR) -type d -print | tr "\n" ":"					  \
		| awk '{print substr ($$1, 1, length($$1) - 1)}')
vpath % secrets/

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

$(NAME): $(MARIADB_PASS) $(FTP_PASS) $(SSL_CERTS) $(SSH_KEY) $(SRC)
	@printf "$(GREEN)Generating and starting containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose up --build --detach
	@echo "#!/bin/sh" > $(NAME)
	@echo >> $(NAME)
	@echo "cd $(SRCDIR) && docker compose logs --follow" >> $(NAME)
	@chmod 755 $(NAME)
	@sleep 5 && docker ps --all

$(MARIADB_PASS): $(SECRETSDIR)
	@printf "$(GREEN)Generating MariaDB passwords...$(RESET)\n"
	@./$(SECRETS_GEN) pass $(SECRETSDIR)/$@

$(FTP_PASS): $(SECRETSDIR)
	@printf "$(GREEN)Generating FTP password...$(RESET)\n"
	@./$(SECRETS_GEN) pass $(SECRETSDIR)/$@

$(SSL_CERTS) &: $(SECRETSDIR)
	@printf "$(GREEN)Generating SSL certificates...$(RESET)\n"
	@./$(SECRETS_GEN) cert

$(SSH_KEY): $(SECRETSDIR)
	@printf "$(GREEN)Generating SSH key...$(RESET)\n"
	@./$(SECRETS_GEN) ssh

$(SECRETSDIR):
	@mkdir --parents secrets/

up:
	@printf "$(GREEN)Starting containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose up --detach
	@sleep 5 && docker ps --all

stop:
	@printf "$(GREEN)Stopping containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose stop
	@sleep 5 && docker ps --all

clean:
	@printf "$(YELLOW)Stopping and removing all containers...$(RESET)\n"
	@cd $(SRCDIR) && docker compose down

fclean: clean
	@printf "$(YELLOW)Removing SSH key...$(RESET)\n"
	@$(RM) ./$(SRCDIR)/requirements/bonus/ftp/*.pub
	@printf "$(YELLOW)Removing all secrets...$(RESET)\n"
	@$(RM) secrets/
	@printf "$(YELLOW)Removing all named volumes...$(RESET)\n"
	@$(shell docker volume rm -f $$(docker volume ls -q) > /dev/null 2>&1)
	@printf "$(YELLOW)Removing all images...$(RESET)\n"
	@$(shell docker rmi -f $$(docker images -q) > /dev/null 2>&1)
	@printf "$(YELLOW)Removing all anonymous volumes, unused networks, and unused build cache...$(RESET)\n"
	@docker system prune --volumes --force
	@$(RM) $(NAME)

re: fclean all

.PHONY: all clean fclean re up