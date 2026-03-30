import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:stakBread/common/service/api/api_service.dart';
import 'package:stakBread/common/service/utils/params.dart';
import 'package:stakBread/common/service/utils/web_service.dart';
import 'package:stakBread/model/general/status_model.dart';

class ResumeService {
  ResumeService._();

  static final ResumeService instance = ResumeService._();

  /// POST `resume/addResume` — multipart: [Params.resumeCaption], [Params.resumeVideoFile], optional [Params.resumePdfFile].
  Future<StatusModel> addResume({
    required String caption,
    required String videoPath,
    String? pdfPath,
  }) async {
    final filesMap = <String, List<XFile?>>{
      Params.resumeVideoFile: [
        XFile(videoPath, name: p.basename(videoPath)),
      ],
    };
    if (pdfPath != null && pdfPath.isNotEmpty) {
      filesMap[Params.resumePdfFile] = [
        XFile(pdfPath, name: p.basename(pdfPath)),
      ];
    }
    return ApiService.instance.multiPartCallApi<StatusModel>(
      url: WebService.resume.addResume,
      param: {Params.resumeCaption: caption},
      filesMap: filesMap,
      fromJson: StatusModel.fromJson,
    );
  }
}
