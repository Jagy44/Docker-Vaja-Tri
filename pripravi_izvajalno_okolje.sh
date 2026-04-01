#!/bin/bash

if [ -z "$1" ]; then
    echo "Uporaba: ./pripravi_izvajalno_okolje.sh https://github.com/Jagy44/Docker-Vaja-Tri.git"
    exit 1
fi

GIT_URL=$1

REPO_NAME=$(basename "$GIT_URL" .git)
rm -rf "$REPO_NAME"
git clone "$GIT_URL"
cd "$REPO_NAME"

if [ -f "run.py" ]; then
    echo "Zaznana Python aplikacija."
    APP_TYPE="python"
elif [ -f "run.sh" ]; then
    echo "Zaznana Bash aplikacija."
    APP_TYPE="bash"
else
    echo "Ni definirane vstopne tocke."
    APP_TYPE="none"
fi

if [ "$APP_TYPE" == "python" ]; then
    cat > Dockerfile <<EOF
FROM python:3.11
WORKDIR /app
COPY . .
RUN if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
CMD ["python", "run.py"]
EOF
elif [ "$APP_TYPE" == "bash" ]; then
    cat > Dockerfile <<EOF
FROM ubuntu
WORKDIR /app
COPY . .
RUN chmod +x run.sh
CMD ["./run.sh"]
EOF
else
    cat > Dockerfile <<EOF
FROM ubuntu
WORKDIR /app
COPY . .
CMD ["sleep", "infinity"]
EOF
fi

echo "Dockerfile ustvarjen."
docker rm -f moj_vsebnik 2>/dev/null
docker rmi -f moja_aplikacija 2>/dev/null
docker build -t moja_aplikacija .
docker run -d --name moj_vsebnik moja_aplikacija
echo "Vsebnik uspesno zagnan!"

