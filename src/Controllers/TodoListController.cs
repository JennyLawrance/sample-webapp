// Controllers/TodoListController.cs
using Microsoft.AspNetCore.Mvc;
using TodoApi.Models;
using TodoApi.Services;

namespace TodoApi.Controllers;

[ApiController]
[Route("[controller]")]
public class TodoListController : ControllerBase
{
    private readonly TodoService _todoService;

    public TodoListController(TodoService todoService)
    {
        _todoService = todoService;
    }

    [HttpGet]
    public IActionResult GetAll()
    {
        return Ok(_todoService.GetAll());
    }

    [HttpGet("{id}")]
    public IActionResult GetById(int id)
    {
        var todo = _todoService.GetById(id);
        if (todo == null)
            return NotFound();
        
        return Ok(todo);
    }

    [HttpPost]
    public IActionResult Create(TodoItem todo)
    {
        var newTodo = _todoService.Create(todo);
        return CreatedAtAction(nameof(GetById), new { id = newTodo.Id }, newTodo);
    }

    [HttpPut("{id}")]
    public IActionResult Update(int id, TodoItem todo)
    {
        if (id != todo.Id)
            return BadRequest();
            
        var updated = _todoService.Update(todo);
        if (!updated)
            return NotFound();
            
        return NoContent();
    }

    [HttpDelete("{id}")]
    public IActionResult Delete(int id)
    {
        var deleted = _todoService.Delete(id);
        if (!deleted)
            return NotFound();
            
        return NoContent();
    }
}