var todo = document.querySelector(".todo");
var todoList = todo.querySelector(".todo-list");
var todoForm = todo.querySelector("form");

todoForm.addEventListener("submit", function (e) {
  e.preventDefault();
  var inputEl = this.children[0];

  var doName = inputEl.value;

  if (!doName.length) {
    return;
  }

  //   todoList.innerHTML += `
  //   <p>${doName}</p>
  //   `;
  var p = document.createElement("p");
  p.innerText = doName;

  var removeBtn = document.createElement("button");
  removeBtn.innerText = "Xóa";
  removeBtn.addEventListener("click", function () {
    handleRemove(p);
  });

  p.append(removeBtn);

  todoList.append(p);

  inputEl.value = "";
});

function handleRemove(todo) {
  todo.remove();
}

// var content = document.querySelector(".content");
// console.log(content.children);
// console.log(content.childNodes);
// content.childNodes[0].data = "Hello F88";

var h2 = document.querySelector(".content h2");
console.log(h2.parentNode.childNodes);
h2.parentNode.childNodes.forEach(function (node) {
  if (node.nodeName === "#comment") {
    node.remove();
  }
  //   console.log(node.textContent.trim());
  //   if (node.nodeName === "#text" && node.textContent.trim() === "") {
  //     node.remove();
  //   }
});

//parentNode
//childNodes
//nextSibling
//previousSibling
