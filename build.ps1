# 必要ファイルの存在確認
$require_files = @(
    "variables.ps1",
    "server_files\configure\wsl.conf",
    "server_files\configure\initialize.sh"
)
$err = $false
foreach ( $filename in $require_files ) {
    if ( -not (Test-Path $filename) ) {
        Write-Host "Not found ${filename}" -ForegroundColor Red
        $err = $true
    }
}
if ($err) {
    exit
}

# 設定変数用のps1読み込み
. .\variables.ps1

# コンテナを作成し、tar.gzとしてexport
docker image build --build-arg "VSCODE_BIN_PATH=${VSCODE_BIN_PATH}" `
    --build-arg "GIT_BIN_PATH=${GIT_BIN_PATH}" `
    --build-arg "DEFAULT_USER=${DEFAULT_USER}" `
    --build-arg "DEFAULT_USER_PASSWORD=${DEFAULT_USER_PASSWORD}" `
    --build-arg "HOSTNAME=${HOSTNAME}" `
    --build-arg "TZ=${TIME_ZONE}" `
    --build-arg "GO_VERSION=${GO_VERSION}" `
    --build-arg "DB_USER=${DB_USER}" `
    --build-arg "DB_USER_PASSWORD=${DB_USER_PASSWORD}" `
    -t ${DISTRO_NAME} .
docker run --name ${DISTRO_NAME} --privileged -td ${DISTRO_NAME}
docker exec -d ${DISTRO_NAME} apt-get install -y systemctl
$containerID = docker ps -a --filter "name=${DISTRO_NAME}" --format "{{.ID}}"
docker export $containerID -o "${DISTRO_NAME}.tar.gz"

# コンテナ、イメージは不要となったため、削除
docker stop $containerID
docker rm $containerID
docker rmi ${DISTRO_NAME}

$wsl_root_dir = 'C:\wsl'
$vm_path = $wsl_root_dir + "\${DISTRO_NAME}\ext4.vhdx"
if ( -not (Test-Path $wsl_root_dir) ) {
    mkdir $wsl_root_dir
}

if ( -not (Test-Path $vm_path) ) {
    wsl --import ${DISTRO_NAME} "C:\wsl\${DISTRO_NAME}" ".\${DISTRO_NAME}.tar.gz"
    wsl -d ${DISTRO_NAME} -e bash /initialize.sh
} else {
    Write-Host "${DISTRO_NAME} already exists. Please run the below command." -ForegroundColor DarkYellow
    Write-Host "wsl --unregister ${DISTRO_NAME}" -ForegroundColor DarkYellow
    Write-Host "./build.ps1" -ForegroundColor DarkYellow
}

Remove-item -Recurse "${DISTRO_NAME}.tar.gz"
