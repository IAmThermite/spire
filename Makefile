dev:
	docker-compose up -d database && \
	docker-compose up -d upload_compiler && \
	docker-compose up web

build_dev:
	docker-compose build

migrate:
	docker-compose run db_migrate

push_upload_compiler:
	docker build --build-arg MIX_ENV=prod -f docker/upload_compiler.dockerfile ./ && \
	aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/upload_compiler && \
	docker tag spire/upload_compiler:latest 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/upload_compiler:latest && \
	docker push 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/upload_compiler:latest && \
	echo "Pushed Upload Compiler Container"

push_spire_web:
	docker build --build-arg MIX_ENV=prod -f docker/spire_web.dockerfile ./ && \
	aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/spire_web && \
	docker tag spire/spire_web:latest 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/spire_web:latest && \
	docker push 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/spire_web:latest && \
	echo "Pushed Spire Web Container"

push_db_migrate:
	docker build --build-arg MIX_ENV=prod -f docker/db_migrate.dockerfile ./
	aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/db_migrate && \
	docker tag spire/db_migrate:latest 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/db_migrate:latest && \
	docker push 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/db_migrate:latest && \
	echo "Pushed DB Migrate Container"

push_all_images: push_spire_web push_upload_compiler push_db_migrate
