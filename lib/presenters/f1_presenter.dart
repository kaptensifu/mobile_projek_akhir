import 'package:projek_akhir/models/driver_model.dart';
import 'package:projek_akhir/models/circuit_model.dart';
import 'package:projek_akhir/models/team_model.dart';
import 'package:projek_akhir/services/api_service.dart';

abstract class DriverView {
  void showLoading();
  void hideLoading();
  void showDriverList(List<Driver> driverList);
  void showCircuitList(List<Circuit> circuitList);
  void showTeamList(List<Team> teamList);
  void showError(String message);
}

class DriverPresenter {
  final DriverView view;

  DriverPresenter(this.view);

  Future<void> loadDriverData(String endpoint) async {
    view.showLoading();
    try {
      final List<dynamic> data = await BaseNetwork.getData(endpoint);
      final driverList = data.map((json) => Driver.fromJson(json)).toList();
      view.showDriverList(driverList);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }
  Future<void> loadTeamData(String endpoint) async {
    view.showLoading();
    try {
      final List<dynamic> data = await BaseNetwork.getData(endpoint);
      final teamList = data.map((json) => Team.fromJson(json)).toList();
      view.showTeamList(teamList);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }

  Future<void> loadCircuitData(String endpoint) async {
    view.showLoading();
    try {
      final List<dynamic> data = await BaseNetwork.getData(endpoint);
      final circuitList = data.map((json) => Circuit.fromJson(json)).toList();
      view.showCircuitList(circuitList);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }
}