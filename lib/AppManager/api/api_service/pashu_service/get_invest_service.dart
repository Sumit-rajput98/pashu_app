import '../../../../model/invest/invest_model.dart';

import '../../constant/api_call.dart';

class GetInvestService {
  Future<List<InvestModel>> fetchInvestmentProjects() async {
    final response = await ApiCall().call(
      url: 'api/invest',
      apiCallType: ApiCallType.get(),
    );

    if (response is List) {
      return response.map((e) => InvestModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load investment projects");
    }
  }
}