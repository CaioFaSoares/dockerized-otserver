#!/bin/bash

printf "[INFO] iniciando download do servidor! \n"

readonly tag=v2.6.1
readonly package=canary-v2.6.1-ubuntu-22.04-executable+server.zip

# verifica se o arquivo zip do servidor está presente
if [ ! -f "server/$package" ]; then
    download_url=https://github.com/opentibiabr/canary/releases/download/$tag/$package
    wget --show-progress -P server/ $download_url

    # se a saída do comando anterior(wget) for diferente de 0 significa que ocorreu um erro
    # https://www.gnu.org/software/wget/manual/html_node/Exit-Status.html
    exit_status=$?
    if [ ! $exit_status -eq 0 ]; then
        echo "[ERROR] erro durante o wget - $exit_status"
        exit 1
    fi
    echo "[INFO] sucesso durante o wget!"

fi

# descompacta os arquivos do servidor na pasta 'server/'
unzip -o -d server/ server/$package &> /dev/null
exit_status=$?
if [ ! $exit_status -eq 0 ]; then
    echo "[ERROR] erro durante o unzip - $exit_status"
    exit 1
fi
echo "[INFO] sucesso durante o unzip!"

# verifica a presença dos arquivos que compõe o servidor
if  [ ! -d "server/" ]                       ||
    [ ! -d "server/data" ]                   ||
    [ ! -d "server/data-otservbr-global" ]   ||
    [ ! -f "server/schema.sql" ]             ||
    [ ! -f "server/canary" ];
then
    echo "[ERROR] arquivos do servidor não foram encontrados! reexecute o script com a flag '-d' ou '--download'"
    exit 1
fi

# copia o 'server/schema.sql' para 'sql/00_schema.sql'
# altera as permissões do arquivo 'server/canary' para que seja possível executa-lo
cp server/schema.sql sql/00_schema.sql 
chmod +x server/canary

# remove arquivos desnecessarios
rm -r server/.github server/cmake server/data-canary server/docker \
    server/docs server/src server/tests server/.editorconfig server/.gitignore \
    server/.reviewdog.yml server/.yamllint.yaml server/canary.rc server/CMakeLists.txt \
    server/CMakePresets.json server/CODE_OF_CONDUCT.md server/gdb_debug server/GitVersion.yml \
    server/Jenkinsfile server/package.json server/recompile.sh server/sonar-project.properties \
    server/start_gdb.sh server/start.sh server/vcpkg.json

echo "[INFO] download concluído, arquivos do servidor extraídos em 'server/'"
echo
