export const isObjectEqual = (obj1, obj2) => {
    if(!isObject(obj1) || !isObject(obj2)) {
        return false;
    }

    // are the references the same?
    if (obj1 === obj2) {
       return true;
    }

   // does it contain objects with the same keys?
   const item1Keys = Object.keys(obj1).sort();
   const item2Keys = Object.keys(obj2).sort();

   if (!isArrayEqual(item1Keys, item2Keys)) {
        return false;
   }

   // does every object in props have the same reference?
   return item2Keys.every(key => {
       const value = obj1[key];
       const nextValue = obj2[key];

       if (value === nextValue) {
           return true;
       }

       // special case for arrays - check one level deep
       return Array.isArray(value) &&
           Array.isArray(nextValue) &&
           isArrayEqual(value, nextValue);
   });
};

export const isObject = (obj) => {
    return obj instanceof Object; 
}

export const isArrayEqual = (array1 = [], array2 = []) => {
    if (array1 === array2) {
        return true;
    }

    // check one level deep
    return array1.length === array2.length &&
        array1.every((item, index) => item === array2[index]);
};