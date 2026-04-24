import 'package:flutter/material.dart';
import '../data/models/medicine_model.dart';
import '../data/services/medicine_service.dart';

class MedicineProvider extends ChangeNotifier {
  List<Medicine> medicines = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  bool isGenerating = false;

  Future<void> fetchMedicines() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    try {
      final result = await MedicineService.getMedicines(page);
      List data = result["data"];

      if (data.isEmpty) {
        hasMore = false;
      } else {
        medicines.addAll(
          data.map((e) => Medicine.fromJson(e)).toList(),
        );
        page++;
      }
    } catch (e) {
      print("Error fetching medicines: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generate(String disease, int total) async {
    isGenerating = true;
    notifyListeners();

    try {
      await MedicineService.generateMedicine(disease, total);

      medicines.clear();
      page = 1;
      hasMore = true;

      await fetchMedicines();
    } catch (e) {
      print("Error generating: $e");
      rethrow;
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }
}