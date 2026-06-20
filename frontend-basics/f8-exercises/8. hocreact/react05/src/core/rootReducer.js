//Quản lý State
export const rootReducer = (state, action) => {
  switch (action.type) {
    case "message/add": {
      const messages = [...state.messages];
      messages.push(action.payload);
      return { ...state, messages };
    }
    case "message/fetch": {
      return { ...state, messages: action.payload };
    }
    default: {
      return state;
    }
  }
};
