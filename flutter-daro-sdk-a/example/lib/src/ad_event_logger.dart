import 'package:flutter/material.dart';

class AdLogController {
  final List<String> _logs = [];

  void addLog(String message) {
    _logs.insert(
      0,
      '[${DateTime.now().toString().substring(11, 19)}] $message',
    );
    if (_logs.length > 50) {
      _logs.removeLast();
    }
    _emit();
  }

  void clearLogs() {
    _logs.clear();
    _emit();
  }

  List<String> get logs => _logs;

  void dispose() {
    clearLogs();
  }

  void Function() _emit = () {};
}

class AdEventLogger extends StatefulWidget {
  final AdLogController controller;
  const AdEventLogger({super.key, required this.controller});

  @override
  State<AdEventLogger> createState() => _AdEventLoggerState();
}

class _AdEventLoggerState extends State<AdEventLogger> {
  @override
  void initState() {
    super.initState();
    widget.controller._emit = () {
      Future.microtask(() {
        if (mounted) {
          setState(() {});
        }
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        SizedBox(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      '로그',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    InkWell(
                      child: const Icon(Icons.clear),
                      onTap: () {
                        widget.controller.clearLogs();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SafeArea(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: widget.controller.logs.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    itemBuilder: (context, index) {
                      return Text(
                        widget.controller.logs[index],
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
