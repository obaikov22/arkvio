import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;

  const UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
  });
}

class UpdateService {
  static const _repoOwner = 'obaikov22';
  static const _repoName = 'arkvio';

  static const _apiUrl =
      'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';

  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Check GitHub for a newer release. Returns null if up-to-date or on error.
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await _dio.get(_apiUrl);
      final tagName = response.data['tag_name'] as String;
      final latestVersion = tagName.replaceFirst('v', '');
      final releaseNotes = (response.data['body'] as String?) ?? '';

      if (!_isNewer(latestVersion, currentVersion)) return null;

      final assets = response.data['assets'] as List<dynamic>;
      final apkAsset = assets.cast<Map<String, dynamic>?>().firstWhere(
        (a) => (a!['name'] as String).endsWith('.apk'),
        orElse: () => null,
      );
      if (apkAsset == null) return null;

      return UpdateInfo(
        version: latestVersion,
        downloadUrl: apkAsset['browser_download_url'] as String,
        releaseNotes: releaseNotes,
      );
    } catch (_) {
      return null;
    }
  }

  /// Download APK to cache directory, return local file path.
  static Future<String> downloadApk(
    String url,
    void Function(int received, int total) onProgress,
  ) async {
    final dir = await getTemporaryDirectory();
    final savePath = '${dir.path}/arkvio_update.apk';

    await _dio.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
      options: Options(responseType: ResponseType.bytes),
    );

    return savePath;
  }

  /// Open the downloaded APK with Android installer.
  static Future<void> installApk(String filePath) async {
    await OpenFile.open(filePath);
  }

  /// Returns true if [latest] > [current] by semver comparison.
  static bool _isNewer(String latest, String current) {
    final l = latest.split('.').map(int.tryParse).toList();
    final c = current.split('.').map(int.tryParse).toList();
    for (int i = 0; i < 3; i++) {
      final li = i < l.length ? (l[i] ?? 0) : 0;
      final ci = i < c.length ? (c[i] ?? 0) : 0;
      if (li > ci) return true;
      if (li < ci) return false;
    }
    return false;
  }
}
