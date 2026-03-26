import express from 'express';
import { engine } from 'express-handlebars';
import expressHandlebarsSections from 'express-handlebars-sections';
import db from './utils/db.js';

const app = express();

app.engine('handlebars', engine({
    defaultLayout: 'main',
  helpers: {
    section: expressHandlebarsSections()
  }
}));
app.set('view engine', 'handlebars');
app.set('views', './views');

app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

app.get('/homelb', async (req, res) => {
  const limit = 20; 
  const page = parseInt(req.query.page) || 1; 
  const offset = (page - 1) * limit;

  try {
    const items = await db('tbl_book').limit(limit).offset(offset);
    const [statsNXB] = await db.raw(`
      SELECT b.book_PublisherName, SUM(c.no_Of_Copies) AS total
      FROM tbl_book b
      JOIN tbl_book_copies c ON b.book_ID = c.book_ID
      GROUP BY b.book_PublisherName
      ORDER BY total DESC LIMIT 3
    `);
    const [topBooks] = await db.raw(`
      SELECT b.book_Title, COUNT(bl.loan_ID) AS total_loans
      FROM tbl_book b
      JOIN tbl_book_loans bl ON b.book_ID = bl.book_ID
      GROUP BY b.book_ID, b.book_Title
      ORDER BY total_loans DESC LIMIT 1
    `);
    const totalCountData = await db('tbl_book').count('* as total');
    const totalPages = Math.ceil(totalCountData[0].total / limit);
    const page_numbers = [];
    for (let i = 1; i <= totalPages; i++) {
      page_numbers.push({
        value: i,
        isCurrent: i === page
      });
    }

    res.render('home', {
      items,
      empty: items.length === 0,
      page_numbers,
      prev_value: page - 1,
      next_value: page + 1,
      is_first: page === 1,
      is_last: page >= totalPages,
      statsNXB: statsNXB, 
      topBook: topBooks[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).send('Lỗi phân trang hoặc kết nối Database!');
  }
});

app.listen(3000, function () {
    console.log('Server đang chạy tại: http://localhost:3000/homelb');
});