import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../models/application_model.dart';
import '../core/services/api_service.dart';

class JobProvider extends ChangeNotifier {
  List<JobModel> _jobs = [];
  List<JobModel> _assignedJobs = [];
  List<ApplicationModel> _applicants = [];
  bool _isLoading = false;

  List<JobModel> get jobs => _jobs;
  List<JobModel> get assignedJobs => _assignedJobs;
  List<ApplicationModel> get applicants => _applicants;
  bool get isLoading => _isLoading;

  Future<void> fetchJobs({bool assigned = false}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/jobs?assigned=$assigned');
      if (res.statusCode == 200) {
        final List parsed = jsonDecode(res.body);
        final list = parsed.map((x) => JobModel.fromJson(x)).toList();
        if (assigned) {
          _assignedJobs = list;
        } else {
          _jobs = list;
        }
      }
    } catch (e) {
      print("Fetch jobs error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createJob(JobModel job) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/jobs', job.toJson());
      if (res.statusCode == 201) {
        final newJob = JobModel.fromJson(jsonDecode(res.body));
        _jobs.insert(0, newJob);
      } else {
        throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to post job');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyForJob(String jobId, String experience, double proposedRate) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/jobs/$jobId/apply', {
        'experience': experience,
        'proposedRate': proposedRate,
      });
      if (res.statusCode != 201) {
        throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to apply for job');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchApplicants(String jobId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/jobs/$jobId/applicants');
      if (res.statusCode == 200) {
        final List parsed = jsonDecode(res.body);
        _applicants = parsed.map((x) => ApplicationModel.fromJson(x)).toList();
      }
    } catch (e) {
      print("Fetch applicants error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptApplicant(String applicationId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/jobs/accept', {
        'applicationId': applicationId,
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final updatedJob = JobModel.fromJson(data['job']);
        
        // Refresh local job listings
        final idx = _jobs.indexWhere((j) => j.id == updatedJob.id);
        if (idx != -1) {
          _jobs[idx] = updatedJob;
        }
        
        // Clear active applicants selection
        _applicants.removeWhere((a) => a.id == applicationId);
      } else {
        throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to hire sitter');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectApplicant(String applicationId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/jobs/reject', {
        'applicationId': applicationId,
      });
      if (res.statusCode == 200) {
        _applicants.removeWhere((a) => a.id == applicationId);
      } else {
        throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to reject applicant');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeJob(String jobId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/jobs/$jobId/complete', {});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final updatedJob = JobModel.fromJson(data['job']);
        final idx = _jobs.indexWhere((j) => j.id == jobId);
        if (idx != -1) {
          _jobs[idx] = updatedJob;
        }
      } else {
        throw Exception(jsonDecode(res.body)['message'] ?? 'Failed to complete job');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
