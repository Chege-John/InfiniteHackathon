function makePayment() {
    const jamboId = document.getElementById('jamboId').value;
    const amount = document.getElementById('amount').value;
  
    fetch('/api/makePayment', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ jamboId, amount }),
    })
      .then(response => response.json())
      .then(data => {
       
        document.getElementById('result').innerText = data.message;
      })
      .catch(error => {
        console.error('Error making payment:', error);
        document.getElementById('result').innerText = 'Error making payment. Please try again.';
      });
  }
  