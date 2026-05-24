FROM pandoc/latex:latest

# eisvogel に必要な LaTeX パッケージを追加インストール
# fmtutil の警告は無視（パッケージ自体は正常にインストールされる）
RUN tlmgr update --self && \
    tlmgr install \
        adjustbox \
        background \
        bidi \
        collectbox \
        csquotes \
        everypage \
        filehook \
        footmisc \
        footnotebackref \
        framed \
        fvextra \
        letltxmacro \
        ly1 \
        mdframed \
        mweights \
        needspace \
        pagecolor \
        sourcecodepro \
        titling \
        ucharcat \
        ulem \
        unicode-math \
        upquote \
        xecjk \
        xurl \
        zref \
        koma-script \
        ; \
    true

# Mermaid CLI のインストール（Chromium + Node.js）
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
RUN apk add --no-cache chromium nodejs npm && \
    npm install -g @mermaid-js/mermaid-cli && \
    npm cache clean --force

# Gen Interface JP フォントをインストール
ARG GEN_INTERFACE_JP_VERSION=0.5.0
RUN apk add --no-cache bash fontconfig unzip && \
    mkdir -p /usr/share/fonts/gen-interface-jp && \
    wget -qO /tmp/GenInterfaceJP.zip \
        "https://github.com/yamatoiizuka/gen-interface-jp/releases/download/v${GEN_INTERFACE_JP_VERSION}/GenInterfaceJP-${GEN_INTERFACE_JP_VERSION}.zip" && \
    unzip -j /tmp/GenInterfaceJP.zip "*.ttf" -d /usr/share/fonts/gen-interface-jp/ && \
    fc-cache -fv && \
    rm /tmp/GenInterfaceJP.zip

# テンプレートをビルドして pandoc のデータディレクトリにインストール
COPY . /eisvogel-src/
WORKDIR /eisvogel-src

RUN bash tools/release.sh docker && \
    mkdir -p /usr/local/share/pandoc/templates && \
    cp dist/eisvogel.latex /usr/local/share/pandoc/templates/ && \
    cp dist/eisvogel.beamer /usr/local/share/pandoc/templates/

# Techolve ブランドアセットを固定パスに配置
RUN mkdir -p /techolve/assets /techolve/filters
COPY resources/logo/techolve.png /techolve/assets/techolve.png
COPY techolve-defaults.yaml /techolve/techolve-defaults.yaml
COPY filters/mermaid.lua /techolve/filters/mermaid.lua
COPY filters/puppeteer-config.json /techolve/filters/puppeteer-config.json

WORKDIR /workspace

ENTRYPOINT ["pandoc"]
