import React, { Component } from "react";
import Products from "../Components/Products";

export default class Category extends Component {
  constructor() {
    super();
    this.state = {
      show: false,
    };
  }
  handleToggle = () => {
    this.setState({ show: !this.state.show });
  };
  render() {
    return (
      <div>
        {this.state.show && <Products />}
        <button onClick={this.handleToggle}>Toggle</button>
      </div>
    );
  }
}

//Mouting -> Component được đưa vào DOM
//Unmouting -> Component bị loại khỏi DOM
