import Testing
@testable import TodoApp

@Suite("TodoApp Tests")
struct TodoAppTests {
    @Test("Todo entity creation")
    func testTodoCreation() {
        let todo = Todo(
            id: 1,
            userId: 1,
            title: "Test Todo",
            completed: false
        )
        
        #expect(todo.id == 1)
        #expect(todo.title == "Test Todo")
        #expect(todo.completed == false)
    }
    
    @Test("Todo update")
    func testTodoUpdate() {
        let todo = Todo(
            id: 1,
            userId: 1,
            title: "Original",
            completed: false
        )
        
        let updated = todo.update(title: "Updated", completed: true)
        
        #expect(updated.title == "Updated")
        #expect(updated.completed == true)
        #expect(updated.id == todo.id)
    }
}

