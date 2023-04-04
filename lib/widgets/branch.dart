import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'TaskClass.dart';
import 'Menu.dart';

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key});
  @override
  State<BranchScreen> createState() => _BranchState();
}

class _BranchState extends State<BranchScreen> {
  final List<Task> _allTasks = [];
  List<Task> _visibleTasks = [];
  bool _onlyFavorite = false;
  bool _hideDone = false;
  String _title = 'Учёба';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 94, 17, 227),
        title: Text(_title),
        actions: [editButton()],
      ),
      body: taskList(_visibleTasks),
      backgroundColor: const Color.fromARGB(255, 63, 150, 255),
      floatingActionButton: _buildAddTaskFab(_allTasks),
    );
  }

  List<Task> _visibleTasksConstructor(
      {required List<Task> tasks,
      required bool onlyFavorite,
      required bool isDone}) {
    List<Task> out = [];
    out.addAll(tasks);
    if (onlyFavorite) {
      out.removeWhere((task) => !task.isFavorite);
    }
    if (_hideDone) {
      out.removeWhere((task) => task.isDone);
    }
    return out;
  }

  Widget _buildAddTaskFab(List tasks) {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(90.0),
      ),
      onPressed: () => _showCreateTaskDialog(context),
      backgroundColor: const Color.fromARGB(255, 58, 183, 133),
      child: const Icon(Icons.add),
    );
  }

  Future<void> _showCreateTaskDialog(BuildContext context) {
    late String text;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Создать задачу'),
          actions: <Widget>[
            Form(child: Builder(builder: (context) {
              return Column(children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Название не может быть пустым';
                    }
                    if (value.length > 40) {
                      return "Название слишком длинное";
                    }
                    return null;
                  },
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  maxLength: 40,
                  decoration: const InputDecoration(
                    labelText: 'Введите название задачи',
                  ),
                  onChanged: (String value) {
                    text = value;
                  },
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Отмена'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Ок'),
                    onPressed: () {
                      if (Form.of(context).validate()) {
                        final newTask = Task(title: text, id: _allTasks.length);
                        setState(() {
                          _allTasks.add(newTask);
                          if (!_onlyFavorite) {
                            _visibleTasks.add(newTask);
                          }
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ]),
              ]);
            }))
          ],
        );
      },
    );
  }

  Widget _taskCard({required List tasks, required int index}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Dismissible(
        background: Container(
          color: Colors.red,
          child: Container(
              margin: const EdgeInsets.only(left: 320.0),
              child: const Icon(Icons.delete_forever)),
        ),
        key: ValueKey<int>(tasks[index].id),
        onDismissed: (DismissDirection direction) {
          setState(() {
            _allTasks.remove(tasks[index]);
            _visibleTasks.remove(tasks[index]);
          });
        },
        direction: DismissDirection.endToStart,
        child: CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          checkboxShape: const CircleBorder(),
          tileColor: Colors.white,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(tasks[index].title),
          value: tasks[index].isDone,
          onChanged: (bool? value) {
            setState(() {
              tasks[index].isDone = !tasks[index].isDone;
            });
          },
          secondary: IconButton(
            iconSize: 30,
            color: Colors.amber,
            isSelected: tasks[index].isFavorite,
            icon: const Icon(
              Icons.star_border,
            ),
            selectedIcon: const Icon(
              Icons.star,
            ),
            onPressed: () {
              setState(() {
                tasks[index].isFavorite = !tasks[index].isFavorite;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget taskList(List<Task> tasks) {
    if (tasks.isNotEmpty) {
      return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return _taskCard(tasks: tasks, index: index);
          });
    } else {
      return _taskListBackground();
    }
  }

  Widget _taskListBackground() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              SvgPicture.asset('assets/todolist_background.svg'),
              SvgPicture.asset('assets/todolist.svg'),
            ],
          ),
          const Text(
            'На данный \n момент задачи \n отсутствуют',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteCompletedConfirmationDialog(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Подтвердите удаление'),
              content: const Text(
                  "Удалить выполненные задачи? Это действие необратимо."),
              actions: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Отмена'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Ок'),
                    onPressed: () {
                      _allTasks.removeWhere((task) => task.isDone);
                      _visibleTasks.removeWhere((task) => task.isDone);
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                  )
                ]),
              ]);
        });
  }

  Future<void> _showEditBranchTitleDialog(BuildContext context) {
    late String text;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Редактировать ветку'),
          actions: <Widget>[
            Form(child: Builder(builder: (context) {
              return Column(children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Название не может быть пустым';
                    }
                    if (value.length > 40) {
                      return 'Название слишком длинное';
                    }
                    return null;
                  },
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  maxLength: 40,
                  decoration: const InputDecoration(
                    labelText: 'Введите название ветки',
                  ),
                  onChanged: (String value) {
                    text = value;
                  },
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Отмена'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Ок'),
                    onPressed: () {
                      if (Form.of(context).validate()) {
                        setState(() {
                          _title = text;
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ]),
              ]);
            }))
          ],
        );
      },
    );
  }

  Widget editButton() {
    List<String> hideDoneButtonText = [
      'Скрыть выполненные',
      'Показать выполненные'
    ];
    List<String> onlyFavoriteButtonText = ['Только избранные', 'Показать все'];
    List<IconData> hideDoneButtonIcon = [
      Icons.check_circle,
      Icons.check_circle_outline
    ];
    List<IconData> onlyFavoriteButtonIcon = [Icons.star, Icons.star_border];

    return PopupMenuButton<Menu>(
        onSelected: (Menu item) {
          if (item == Menu.hideDone) {
            setState(() {
              _hideDone = !_hideDone;
              _visibleTasks = _visibleTasksConstructor(
                  tasks: _allTasks,
                  onlyFavorite: _onlyFavorite,
                  isDone: _hideDone);
            });
          }
          if (item == Menu.onlyFavorite) {
            setState(() {
              _onlyFavorite = !_onlyFavorite;
              _visibleTasks = _visibleTasksConstructor(
                  tasks: _allTasks,
                  onlyFavorite: _onlyFavorite,
                  isDone: _hideDone);
            });
          }
          if (item == Menu.deleteDone) {
            _showDeleteCompletedConfirmationDialog(context);
          }
          if (item == Menu.editThread) {
            _showEditBranchTitleDialog(context);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              PopupMenuItem<Menu>(
                  value: Menu.hideDone,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: Icon(hideDoneButtonIcon[_hideDone ? 1 : 0]),
                    title: Text(hideDoneButtonText[_hideDone ? 1 : 0]),
                  )),
              PopupMenuItem<Menu>(
                value: Menu.onlyFavorite,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Icon(onlyFavoriteButtonIcon[_onlyFavorite ? 1 : 0]),
                  title: Text(onlyFavoriteButtonText[_onlyFavorite ? 1 : 0]),
                ),
              ),
              const PopupMenuItem<Menu>(
                value: Menu.deleteDone,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  leading: Icon(Icons.delete_forever),
                  title: Text('Удалить выполненные'),
                ),
              ),
              const PopupMenuItem<Menu>(
                value: Menu.editThread,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  leading: Icon(Icons.edit),
                  title: Text('Редактировать ветку'),
                ),
              ),
            ]);
  }
}
