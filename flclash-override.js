// FlClash 覆写脚本 — 注入过滤规则集 + DNS
// 用法：FlClash → 工具 → 进阶配置 → 脚本 → 新建 → 粘贴本文件全部内容 → 保存并启用
// 会向现有配置 prepend 规则 + 规则集 + 覆盖 DNS
const main = (config) => {
  // 注入规则集
  config['rule-providers'] = {
    ...(config['rule-providers'] || {}),
    porn: {
      type: 'http',
      behavior: 'domain',
      format: 'mrs',
      url: 'https://cdn.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@meta/geo/geosite/category-porn.mrs',
      path: './ruleset/category-porn.mrs',
      interval: 86400,
    },
    custom: {
      type: 'http',
      behavior: 'domain',
      url: 'https://cdn.jsdelivr.net/gh/aggjjfd/dns-filter@main/clash-custom-blocklist.yaml',
      path: './ruleset/custom-blocklist.yaml',
      interval: 86400,
    },
  };

  // 在最前插入 REJECT 规则
  config.rules = [
    'RULE-SET,custom,REJECT',
    'RULE-SET,porn,REJECT',
    ...(config.rules || []),
  ];

  // 覆盖 DNS
  config.dns = {
    enable: true,
    nameserver: ['https://doh.cleanbrowsing.org/doh/family-filter/'],
  };

  return config;
};
