import bcrypt from 'bcrypt';

async function createPasswordHash() {
  const password = 'demo123';
  const hash = await bcrypt.hash(password, 10);
  console.log('Password:', password);
  console.log('Hash:', hash);
  
  // Test the hash
  const isValid = await bcrypt.compare(password, hash);
  console.log('Hash validation:', isValid);
}

createPasswordHash();