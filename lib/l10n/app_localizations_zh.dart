// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Brew Master';

  @override
  String get tabDashboard => '仪表板';

  @override
  String get tabInstalled => '已安装';

  @override
  String get tabDiscover => '发现';

  @override
  String get tabUpdates => '更新';

  @override
  String get tabServices => '服务';

  @override
  String get tabCleanup => '清理';

  @override
  String get tabRecommend => '推荐';

  @override
  String get tabSettings => '系统设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsInstantHint => '更改即时生效，可直接返回。';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get langSystem => '跟随系统';

  @override
  String get langEnglish => '英文';

  @override
  String get langChineseSimplified => '简体中文';

  @override
  String get langChineseTraditional => '繁體中文';

  @override
  String get actionCheckUpdates => '检查更新';

  @override
  String get actionViewUpdates => '查看更新';

  @override
  String get actionCleanNow => '立即清理';

  @override
  String get actionManageServices => '管理服务';

  @override
  String get labelHome => '主页';

  @override
  String get actionClose => '关闭';

  @override
  String get actionRefresh => '刷新';

  @override
  String get actionStart => '启动';

  @override
  String get actionStop => '停止';

  @override
  String get actionRestart => '重启';

  @override
  String get actionViewLogsDir => '查看日志目录';

  @override
  String get labelPorts => '端口: ';

  @override
  String get labelResources => '资源: ';

  @override
  String get actionCancel => '取消';

  @override
  String get actionUninstall => '卸载';

  @override
  String get textIrreversible => '该操作不可撤销。';

  @override
  String get actionBulkUninstall => '批量卸载';

  @override
  String get actionClearSelection => '清除选择';

  @override
  String get actionOpenHomepage => '主页 ↗';

  @override
  String get actionReinstall => '重新安装';

  @override
  String get actionLoadFiles => '加载文件列表（基于 brew ls）';

  @override
  String get actionLoadAlternatives => '加载历史版本';

  @override
  String get actionInstallThisVersion => '安装该版本';

  @override
  String get titleManualExtractInstall => '手动提取并安装指定版本';

  @override
  String get actionExtractInstall => '提取并安装';

  @override
  String get warnMayUpgradeDeps => '可能会升级依赖';

  @override
  String get actionContinue => '继续';

  @override
  String get actionRetest => '重新检查';

  @override
  String get actionSaveAndCheck => '保存并检测';

  @override
  String get actionOpenHomebrewSite => '打开 Homebrew 官网';

  @override
  String get actionIInstalledRecheck => '我已安装，重新检测';

  @override
  String get messageOpenHomepageFailed => '无法打开主页链接';

  @override
  String get dashboardFetching => '正在获取…';

  @override
  String get dashboardPleaseWait => '请稍候';

  @override
  String dashboardFoundUpdatesN(Object count) {
    return '发现 $count 个更新';
  }

  @override
  String get dashboardNoUpdates => '没有可更新';

  @override
  String get dashboardTapForDetails => '点击查看详情';

  @override
  String get dashboardHealthOk => '系统健康（通过所有检查）';

  @override
  String dashboardFoundIssuesN(Object count) {
    return '发现 $count 个问题';
  }

  @override
  String get dashboardCleanupTitle => '系统清理';

  @override
  String get dashboardCalculating => '计算中…';

  @override
  String get dashboardNoCleanupNeeded => '无需清理';

  @override
  String dashboardCanFreeSize(Object size) {
    return '可释放 $size';
  }

  @override
  String get dashboardServicesTitle => '后台服务';

  @override
  String get dashboardRunning => '运行：';

  @override
  String get dashboardStopped => '停止：';

  @override
  String get updatesDialogTitle => '可能会升级依赖';

  @override
  String updatesDialogContentPrefix(Object name) {
    return '升级 $name 可能会同时升级：\n';
  }

  @override
  String get updatesUpgradeAll => '全部升级';

  @override
  String updatesUpgradeSelected(Object count) {
    return '升级所选 ($count)';
  }

  @override
  String get updatesSearchHint => '搜索待更新…';

  @override
  String get updatesSortByName => '按名称';

  @override
  String get updatesSortBySize => '按大小';

  @override
  String get updatesAllUpToDate => '太棒了！所有工具都已是最新版本。';

  @override
  String updatesEstimatedDownload(Object size) {
    return '预计下载: $size';
  }

  @override
  String updatesMayAffectDeps(Object count) {
    return '提示：可能还会影响 $count 个依赖包';
  }

  @override
  String get updatesViewChangelog => '查看更新日志';

  @override
  String get updatesUpgrading => '进行中';

  @override
  String get updatesUpgrade => '升级';

  @override
  String get updatesChecking => '正在检查更新…';

  @override
  String get servicesNoResults => '没有符合条件的服务';

  @override
  String get servicesSearchHint => '搜索服务…';

  @override
  String get servicesCopyPath => '复制路径';

  @override
  String get servicesProcessing => '处理中…';

  @override
  String get servicesDetails => '详情';

  @override
  String get healthTitle => '系统健康检查';

  @override
  String get healthIntroOk => '您的 Homebrew 环境已通过以下所有检查。';

  @override
  String get healthDoctorTitle => 'brew doctor 未发现问题';

  @override
  String get healthDoctorDescription => '所有检查通过';

  @override
  String get healthRepoTitle => 'Homebrew 核心代码库状态';

  @override
  String get healthPathTitle => '系统路径 (PATH) 配置';

  @override
  String get healthXcodeTitle => 'Xcode 命令行工具';

  @override
  String get healthMissingTitle => '缺失的依赖项';

  @override
  String get healthChecking => '检查中…';

  @override
  String get healthAnalyzing => '正在分析 brew doctor 输出…';

  @override
  String get healthReadingPrefix => '读取前缀路径…';

  @override
  String get healthCheckingPath => '检查 PATH…';

  @override
  String get healthCheckingXcode => '检查安装状态…';

  @override
  String get healthScanningDeps => '扫描缺失依赖…';

  @override
  String get healthNoMissingDeps => '未发现缺失依赖';

  @override
  String healthFoundIssues(Object count) {
    return '发现 $count 条提示/问题';
  }

  @override
  String healthCheckFailed(Object error) {
    return '检查失败：$error';
  }

  @override
  String get healthCheckComplete => '检查完成 ✅';

  @override
  String get cleanupTitle => '系统清理';

  @override
  String cleanupTotal(Object size) {
    return '总计可释放：$size';
  }

  @override
  String get cleanupGroupCache => '缓存的下载文件';

  @override
  String get cleanupGroupOutdated => '过时的软件包';

  @override
  String get cleanupGroupUnlinked => '未链接的旧版本';

  @override
  String get cleanupEmpty => '没有可清理的项目';

  @override
  String cleanupSelectedCount(Object count) {
    return '已选择 $count 项';
  }

  @override
  String get cleanupDone => '清理完成';

  @override
  String get installedTitle => '已安装的软件包';

  @override
  String get searchInstalledHint => '搜索已安装的包…';

  @override
  String get selectPackagePlaceholder => '选择一个包查看详情';

  @override
  String statusTotalPackages(Object count) {
    return '共 $count 个包';
  }

  @override
  String statusLastRefresh(Object time) {
    return '上次刷新：$time';
  }

  @override
  String get filterAll => '全部';

  @override
  String get filterFormulae => 'Formulae';

  @override
  String get filterCasks => 'Casks';

  @override
  String get actionViewDetails => '查看详情';

  @override
  String get actionCopyPath => '复制路径';

  @override
  String get actionInstallInProgress => '安装中…';

  @override
  String get actionLastOutput => '最后输出：';

  @override
  String get actionLoadFailed => '加载失败：';

  @override
  String get actionNoFilesFound => '未找到文件';

  @override
  String actionUninstallConfirm(Object name) {
    return '卸载 $name？';
  }

  @override
  String actionBulkUninstallConfirm(Object count) {
    return '卸载选中的 $count 个包？';
  }

  @override
  String get actionHomepage => '主页：';

  @override
  String get actionLicense => '许可证：';

  @override
  String get actionInfo => '信息';

  @override
  String get actionFiles => '文件';

  @override
  String get actionOptions => '选项';

  @override
  String get actionDependencies => '依赖关系';

  @override
  String get actionHistoricalVersions => '历史版本';

  @override
  String get actionNoVersionedFormulae => '未发现版本化配方。';

  @override
  String get actionExtractInstallHint => '提示：很多配方没有维护版本化别名，可使用下方\"提取并安装\"直接指定版本。';

  @override
  String get actionCaskNotSupported => '历史版本与编译选项当前仅支持 Formula。';

  @override
  String get actionLearnMore => '了解更多';

  @override
  String get actionInstall => '安装';

  @override
  String get actionInstalling => '安装中…';

  @override
  String get actionInstalled => '已安装';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant(): super('zh_Hant');

  @override
  String get appTitle => 'Brew Master';

  @override
  String get tabDashboard => '儀表板';

  @override
  String get tabInstalled => '已安裝';

  @override
  String get tabDiscover => '探索';

  @override
  String get tabUpdates => '更新';

  @override
  String get tabServices => '服務';

  @override
  String get tabCleanup => '清理';

  @override
  String get tabRecommend => '推薦';

  @override
  String get tabSettings => '系統設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsTheme => '主題';

  @override
  String get settingsInstantHint => '更改即時生效，可直接返回。';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get langSystem => '跟隨系統';

  @override
  String get langEnglish => '英文';

  @override
  String get langChineseSimplified => '簡體中文';

  @override
  String get langChineseTraditional => '繁體中文';

  @override
  String get actionCheckUpdates => '檢查更新';

  @override
  String get actionViewUpdates => '查看更新';

  @override
  String get actionCleanNow => '立即清理';

  @override
  String get actionManageServices => '管理服務';

  @override
  String get labelHome => '主頁';

  @override
  String get actionClose => '關閉';

  @override
  String get actionRefresh => '重新整理';

  @override
  String get actionStart => '啟動';

  @override
  String get actionStop => '停止';

  @override
  String get actionRestart => '重啟';

  @override
  String get actionViewLogsDir => '查看日誌目錄';

  @override
  String get labelPorts => '連接埠: ';

  @override
  String get labelResources => '資源: ';

  @override
  String get actionCancel => '取消';

  @override
  String get actionUninstall => '卸載';

  @override
  String get textIrreversible => '此操作無法復原。';

  @override
  String get actionBulkUninstall => '批量卸載';

  @override
  String get actionClearSelection => '清除選擇';

  @override
  String get actionOpenHomepage => '主頁 ↗';

  @override
  String get actionReinstall => '重新安裝';

  @override
  String get actionLoadFiles => '載入檔案清單（基於 brew ls）';

  @override
  String get actionLoadAlternatives => '載入歷史版本';

  @override
  String get actionInstallThisVersion => '安裝此版本';

  @override
  String get titleManualExtractInstall => '手動解壓並安裝指定版本';

  @override
  String get actionExtractInstall => '解壓並安裝';

  @override
  String get warnMayUpgradeDeps => '可能會升級依賴';

  @override
  String get actionContinue => '繼續';

  @override
  String get actionRetest => '重新檢查';

  @override
  String get actionSaveAndCheck => '保存並檢測';

  @override
  String get actionOpenHomebrewSite => '打開 Homebrew 官網';

  @override
  String get actionIInstalledRecheck => '我已安裝，重新檢測';

  @override
  String get messageOpenHomepageFailed => '無法打開主頁連結';

  @override
  String get dashboardFetching => '正在取得…';

  @override
  String get dashboardPleaseWait => '請稍候';

  @override
  String dashboardFoundUpdatesN(Object count) {
    return '發現 $count 個更新';
  }

  @override
  String get dashboardNoUpdates => '沒有可更新';

  @override
  String get dashboardTapForDetails => '點擊查看詳情';

  @override
  String get dashboardHealthOk => '系統健康（通過所有檢查）';

  @override
  String dashboardFoundIssuesN(Object count) {
    return '發現 $count 個問題';
  }

  @override
  String get dashboardCleanupTitle => '系統清理';

  @override
  String get dashboardCalculating => '計算中…';

  @override
  String get dashboardNoCleanupNeeded => '無需清理';

  @override
  String dashboardCanFreeSize(Object size) {
    return '可釋放 $size';
  }

  @override
  String get dashboardServicesTitle => '後台服務';

  @override
  String get dashboardRunning => '運行：';

  @override
  String get dashboardStopped => '停止：';

  @override
  String get updatesDialogTitle => '可能會升級依賴';

  @override
  String updatesDialogContentPrefix(Object name) {
    return '升級 $name 可能也會升級：\n';
  }

  @override
  String get updatesUpgradeAll => '全部升級';

  @override
  String updatesUpgradeSelected(Object count) {
    return '升級所選 ($count)';
  }

  @override
  String get updatesSearchHint => '搜尋待更新…';

  @override
  String get updatesSortByName => '按名稱';

  @override
  String get updatesSortBySize => '按大小';

  @override
  String get updatesAllUpToDate => '太棒了！所有工具皆為最新版本。';

  @override
  String updatesEstimatedDownload(Object size) {
    return '預計下載：$size';
  }

  @override
  String updatesMayAffectDeps(Object count) {
    return '提示：可能還會影響 $count 個依賴包';
  }

  @override
  String get updatesViewChangelog => '查看更新日誌';

  @override
  String get updatesUpgrading => '進行中';

  @override
  String get updatesUpgrade => '升級';

  @override
  String get updatesChecking => '正在檢查更新…';

  @override
  String get servicesNoResults => '沒有符合條件的服務';

  @override
  String get servicesSearchHint => '搜尋服務…';

  @override
  String get servicesCopyPath => '複製路徑';

  @override
  String get servicesProcessing => '處理中…';

  @override
  String get servicesDetails => '詳情';

  @override
  String get healthTitle => '系統健康檢查';

  @override
  String get healthIntroOk => '您的 Homebrew 環境已通過以下所有檢查。';

  @override
  String get cleanupTitle => '系統清理';

  @override
  String cleanupTotal(Object size) {
    return '總計可釋放：$size';
  }

  @override
  String get cleanupGroupCache => '快取的下載檔案';

  @override
  String get cleanupGroupOutdated => '過時的軟體包';

  @override
  String get cleanupGroupUnlinked => '未連結的舊版本';

  @override
  String get cleanupEmpty => '沒有可清理的項目';

  @override
  String cleanupSelectedCount(Object count) {
    return '已選擇 $count 項';
  }

  @override
  String get cleanupDone => '清理完成';

  @override
  String get installedTitle => '已安裝的軟體包';

  @override
  String get searchInstalledHint => '搜尋已安裝的包…';

  @override
  String get selectPackagePlaceholder => '選擇一個包查看詳情';

  @override
  String statusTotalPackages(Object count) {
    return '共 $count 個包';
  }

  @override
  String statusLastRefresh(Object time) {
    return '上次刷新：$time';
  }

  @override
  String get filterAll => '全部';

  @override
  String get filterFormulae => 'Formulae';

  @override
  String get filterCasks => 'Casks';
}
