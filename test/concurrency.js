const ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]; // Array of ids
const responses = await Promise.all(
	ids.map(async id => {
		const res = await fetch(
			`https://main.d3f2wn27e6ngc4.amplifyapp.com/`
		); // Send request for each id
	})
);
console.log(responses)

// const num = 6;

// const result = (num % 2  != 0) ? "odd" : "even";

// // display the result

// console.log(`Number is ${result}.`);