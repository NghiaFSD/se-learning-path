//Định nghĩa core component

var Component = {
  create: function (name, handle) {
    var componentFunc = function () {
      return Reflect.construct(HTMLElement, [], this.constructor);
    };

    componentFunc.prototype = Object.create(HTMLElement.prototype);

    componentFunc.prototype.constructor = componentFunc;
    componentFunc.prototype.connectedCallback = handle;

    customElements.define(name, componentFunc);
  },
};
