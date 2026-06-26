export const getLocalStorage = (key) => {
  try {
    if (localStorage.getItem(key)) {
      const messages = JSON.parse(localStorage.getItem(key)); //Nếu không phải JSON
      return messages;
    }
  } catch (e) {
    console.log(e.message);
  }
  return [];
};

export const setLocalStorage = (key, value) => {
  value = JSON.stringify(value);
  localStorage.setItem(key, value);
};
