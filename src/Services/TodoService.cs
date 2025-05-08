using TodoApi.Models;

namespace TodoApi.Services;

public class TodoService
{
    private readonly List<TodoItem> _todos = new();
    private int _nextId = 1;

    public IEnumerable<TodoItem> GetAll()
    {
        return _todos;
    }

    public TodoItem? GetById(int id)
    {
        return _todos.FirstOrDefault(t => t.Id == id);
    }

    public TodoItem Create(TodoItem todo)
    {
        // Test out exception code path
        // Todo: remove after testing
        if (_nextId++ % 5 == 0)
        {
            throw new Exception("Not a valid item");
        }

        todo.Id = _nextId++;
        _todos.Add(todo);
        return todo;
    }

    public bool Update(TodoItem todo)
    {
        var index = _todos.FindIndex(t => t.Id == todo.Id);
        if (index == -1)
            return false;
            
        _todos[index] = todo;
        return true;
    }

    public bool Delete(int id)
    {
        var todo = _todos.FirstOrDefault(t => t.Id == id);
        if (todo == null)
            return false;
            
        _todos.Remove(todo);
        return true;
    }
}