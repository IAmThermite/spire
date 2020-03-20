build:
	mix deps.get && \
	docker-compose build

dev:
	docker-compose up -d database && \
	docker-compose up -d upload_compiler && \
	docker-compose up web

migrate:
	docker-compose run db_migrate

push_upload_compiler:
	aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/upload_compiler && \
	docker tag spire/upload_compiler:latest 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/upload_compiler:latest && \
	docker push 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/upload_compiler:latest && \
	echo "Pushed Upload Compiler Container"

push_spire_web:
	aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/spire_web && \
	docker tag spire/spire_web:latest 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/spire_web:latest && \
	docker push 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/spire_web:latest && \
	echo "Pushed Spire Web Container"

push_db_migrate:
	aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/db_migrate && \
	docker tag spire/db_migrate:latest 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/db_migrate:latest && \
	docker push 903768974813.dkr.ecr.us-east-2.amazonaws.com/spire/db_migrate:latest && \
	echo "Pushed DB Migrate Container"

push_all_images: push_spire_web push_upload_compiler push_db_migrate
