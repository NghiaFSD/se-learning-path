import React, { createContext, useReducer } from "react";
import { rootReducer } from "./rootReducer";
export const ProviderContext = createContext();
const Provider = ({ children }) => {
  const initialState = {
    messages: [],
  };
  const [state, dispatch] = useReducer(rootReducer, initialState);

  return (
    <ProviderContext.Provider
      value={{
        state,
        dispatch,
      }}
    >
      {children}
    </ProviderContext.Provider>
  );
};

export default Provider;
