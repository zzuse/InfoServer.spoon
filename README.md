# InfoServer.spoon

Simple HTTP server for receiving tasks and alerts.

## Usage

### Task Route
Post a task to be displayed on the screen (transparent, lime green, huge text).
```bash
curl -X POST -H "Content-Type: application/json" -d '{"doer": "Me", "task_name": "My Task", "time_slot": "9:00 - 10:00"}' http://localhost:9181/task
```

### Alert Route
Show a large centralized alert message.
```bash
curl -X POST -H "Content-Type: application/json" -d '{"message": "Hello World"}' http://localhost:9181/alert
```
