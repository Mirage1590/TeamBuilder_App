const axios = require('axios');
const { faker } = require('@faker-js/faker');

// --- ตั้งค่าการเชื่อมต่อ PocketBase ของคุณ ---
const POCKETBASE_URL = 'http://127.0.0.1:8090'; // << เปลี่ยนเป็น URL ของ PocketBase คุณ
const COLLECTION_NAME = 'product'; // << ชื่อ Collection ของคุณ
const TOTAL_PRODUCTS = 100; // จำนวนสินค้าที่ต้องการสร้าง

// ฟังก์ชันสำหรับสร้างข้อมูลสินค้าสุ่ม 1 รายการ
function createRandomProduct() {
  return {
    name: faker.commerce.productName(),
    price: parseFloat(faker.commerce.price({ min: 100, max: 5000 })),
    // เปลี่ยนไปใช้ picsum.photos ซึ่งมีความเสถียรกว่ามาก
    imageUrl: `https://picsum.photos/seed/${faker.string.uuid()}/640/480`,
  };
}

// ฟังก์ชันหลักสำหรับส่งข้อมูลไปยัง PocketBase
async function seedProducts() {
  console.log(`🚀 เริ่มสร้างข้อมูลสินค้าจำนวน ${TOTAL_PRODUCTS} รายการ...`);

  const API_ENDPOINT = `${POCKETBASE_URL}/api/collections/${COLLECTION_NAME}/records`;

  for (let i = 0; i < TOTAL_PRODUCTS; i++) {
    const productData = createRandomProduct();

    try {
      // ส่ง HTTP POST request เพื่อสร้าง record ใหม่
      await axios.post(API_ENDPOINT, productData, {
        headers: {
          'Content-Type': 'application/json',
          // หากมีการตั้งค่า Admin/API key สามารถเพิ่ม Header Authorization ได้ที่นี่
        },
      });
      console.log(`[${i + 1}/${TOTAL_PRODUCTS}] ✅ สร้างสินค้าสำเร็จ: ${productData.name}`);
    } catch (error) {
      // แสดงข้อผิดพลาดหากไม่สามารถสร้าง record ได้
      console.error(`[${i + 1}/${TOTAL_PRODUCTS}] ❌ เกิดข้อผิดพลาดในการสร้างสินค้า: ${productData.name}`);
      if (error.response) {
        console.error('   Error Details:', JSON.stringify(error.response.data, null, 2));
      } else {
        console.error('   Error:', error.message);
      }
    }
    
    // หน่วงเวลาเล็กน้อยเพื่อไม่ให้ส่ง request เร็วเกินไป
    await new Promise(resolve => setTimeout(resolve, 50)); 
  }

  console.log(`\n🎉 การสร้างข้อมูลสินค้าทั้งหมด ${TOTAL_PRODUCTS} รายการเสร็จสิ้น!`);
}

// เริ่มการทำงานของสคริปต์
seedProducts();