GIT_COMMIT_HASH := $(shell git log -1 --format=%H)

dev:
	docker-compose up -d database && \
	docker-compose up -d upload_compiler && \
	docker-compose up web

migrate:
	docker-compose run db_migrate

push_upload_compiler:
	docker build -t spire/upload_compiler:latest -f docker/upload_compiler.dockerfile ./ && \
	aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/upload_compiler && \
	docker tag spire/upload_compiler:latest 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/upload_compiler:latest && \
	docker tag spire/upload_compiler:latest 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/upload_compiler:$(GIT_COMMIT_HASH) && \
	docker push 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/upload_compiler:latest && \
	docker push 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/upload_compiler:$(GIT_COMMIT_HASH) && \
	echo "Pushed Upload Compiler Container"

push_spire_web:
	docker build -t spire/spire_web:latest -f docker/spire_web.dockerfile ./ && \
	aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/spire_web && \
	docker tag spire/spire_web:latest 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/spire_web:latest && \
	docker tag spire/spire_web:latest 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/spire_web:$(GIT_COMMIT_HASH) && \
	docker push 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/spire_web:latest && \
	docker push 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/spire_web:$(GIT_COMMIT_HASH) && \
	echo "Pushed Spire Web Container"

push_db_migrate:
	docker build -t spire/db_migrate:latest -f docker/db_migrate.dockerfile ./
	aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/db_migrate && \
	docker tag spire/db_migrate:latest 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/db_migrate:latest && \
	docker tag spire/db_migrate:latest 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/db_migrate:$(GIT_COMMIT_HASH) && \
	docker push 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/db_migrate:latest && \
	docker push 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/db_migrate:$(GIT_COMMIT_HASH) && \
	echo "Pushed DB Migrate Container"

push_all_images: push_spire_web push_upload_compiler push_db_migrate
