class TaskModel {
  final int id;
  final String title;
  final String description;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['task_id'];
    int parsedId = 0;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId != null) {
      parsedId = int.tryParse(rawId.toString()) ?? 0;
    }

    // Laravel me status 0/1, '0'/'1', boolean, ya string ho sakta hai
    final rawStatus = json['is_completed'] ?? json['completed'] ?? json['status'];
    final bool completed = rawStatus == 1 ||
        rawStatus == '1' ||
        rawStatus == true ||
        rawStatus == 'true' ||
        rawStatus == 'completed';

    return TaskModel(
      id: parsedId,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isCompleted: completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
    };
  }
}