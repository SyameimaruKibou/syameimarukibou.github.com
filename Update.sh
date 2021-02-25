npm install -g hexo-cli
npm install
sed -i'' "s~git@github.com:SyameimaruKibou/syameimarukibou.github.io.git~https://${GIT_REPO_TOKEN}@github.com/SyameimaruKibou/syameimarukibou.github.io.git~" _config.yml
cat _config.yml