export DEBIAN_FRONTEND=noninteractive
apt-get update -y 
apt-get install -y software-properties-common 
add-apt-repository -y ppa:git-core/ppa 
apt-get update -y 
apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    bison \
    curl \
    ca-certificates \
    dnsutils \
    git \
    jq \
    libffi-dev \
    libgdbm-dev \
    libreadline-dev \
    libssl-dev \
    libunwind8 \
    libyaml-dev \
    locales \
    python3-pip \
    rsync \
    supervisor \
    sudo \
    time \
    tzdata \
    unzip \
    upx \
    wget \
    zip \
    zlib1g-dev \
    zstd 
ln -sf /usr/bin/python3 /usr/bin/python 
ln -sf /usr/bin/pip3 /usr/bin/pip 
rm -rf /var/lib/apt/lists/*
mkdir -p actions-runner/_work

ARCH="x64"
GH_RUNNER_VERSION=$(curl -fsSL "https://api.github.com/repos/actions/runner/releases/latest" | jq -r '.tag_name' | cut -c2-) 
curl -O -L "https://github.com/actions/runner/releases/download/v$${GH_RUNNER_VERSION}/actions-runner-linux-$${ARCH}-$${GH_RUNNER_VERSION}.tar.gz" 
tar -xzf "actions-runner-linux-$${ARCH}-$${GH_RUNNER_VERSION}.tar.gz" 
rm -f "actions-runner-linux-$${ARCH}-$${GH_RUNNER_VERSION}.tar.gz"
mkdir /opt/hostedtoolcache
chmod +x /opt/entrypoint.sh

printf 'ALL            ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers

user=actions
group=actions

groupadd $${group}
useradd -g $${group} -m $${user}
chown -R $${user}:$${group} /actions-runner /opt/hostedtoolcache
