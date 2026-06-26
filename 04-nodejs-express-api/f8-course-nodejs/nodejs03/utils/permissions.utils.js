module.exports = {
  isPermission: (obj, value) => {
    //obj: role, user
    return obj.permissions.find((item) => item.value === value);
  },
  isRole: (obj, id) => {
    return obj.roles.find((item) => item.id === id);
  },
};
