import 'package:flutter/material.dart';

class AdLogController {
  final List<String> _logs = [];

  void addLog(String message) {
    _logs.insert(0, '${DateTime.now().toString().substring(11, 19)}: $message');
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
        Container(
          height: 200,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('로그', style: TextStyle(fontWeight: FontWeight.bold)),
                  Spacer(),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        widget.controller.clearLogs();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: widget.controller.logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(widget.controller.logs[index], style: const TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
