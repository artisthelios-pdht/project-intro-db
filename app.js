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

//detail
app.get('/detail/:id', async (req, res) => {
  const bookId = parseInt(req.params.id);
  console.log("ID sách đang tìm kiếm là:", bookId);

  try {
    const bookInfo = await db('tbl_book')
      .leftJoin('tbl_book_authors', 'tbl_book.book_ID', 'tbl_book_authors.book_ID')
      .where('tbl_book.book_ID', bookId)
      .select(
        'tbl_book.book_ID',
        'tbl_book.book_Title',
        'tbl_book.book_PublisherName',
        'tbl_book_authors.author_Name'
      )
      .first();
    if (!bookInfo) {
      return res.status(404).send('Không tìm thấy cuốn sách này trong hệ thống!');
    }

    const copies = await db('tbl_book_copies')
      .join('tbl_library_branch', 'tbl_book_copies.branch_ID', 'tbl_library_branch.branch_ID')
      .where('tbl_book_copies.book_ID', bookId)
      .select(
        'tbl_library_branch.branch_Name',
        'tbl_library_branch.branch_Address',
        'tbl_book_copies.no_Of_Copies'
      );

    const loansData = await db('tbl_book_loans')
      .join('tbl_borrower', 'tbl_book_loans.card_No', 'tbl_borrower.card_No')
      .where('tbl_book_loans.book_ID', bookId)
      .select(
        'tbl_borrower.card_No',
        'tbl_borrower.borrower_Name',
        'tbl_book_loans.date_Out',
        'tbl_book_loans.date_Due'
      );

    const currentDate = new Date();
    const formattedLoans = loansData.map(loan => {
      const dueDate = new Date(loan.date_Due);
      const isOverdue = dueDate < currentDate;

      const formatDate = (dateString) => {
        const d = new Date(dateString);
        return `${d.getDate().toString().padStart(2, '0')}/${(d.getMonth() + 1).toString().padStart(2, '0')}/${d.getFullYear()}`;
      };

      return {
        ...loan,
        date_Out: formatDate(loan.date_Out),
        date_Due: formatDate(loan.date_Due),
        status_text: isOverdue ? 'Quá hạn' : 'Đang mượn',
        status_color: isOverdue ? 'danger' : 'warning text-dark'
      };
    });

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

    const detailData = {
      book: bookInfo,
      copies: copies,
      loans: formattedLoans,
      statsNXB: statsNXB,
      topBook: topBooks[0]
    };

    res.render('detail', detailData);

  } catch (err) {
    console.error(err);
    res.status(500).send('Lỗi kết nối Database khi tải trang chi tiết!');
  }
});

// search
app.get('/search', async (req, res) => {
  const keyword = req.query.q || '';

  try {
    const items = await db('tbl_book')
      .leftJoin('tbl_book_authors', 'tbl_book.book_ID', 'tbl_book_authors.book_ID')
      .where('tbl_book.book_Title', 'like', `%${keyword}%`)
      .orWhere('tbl_book_authors.author_Name', 'like', `%${keyword}%`)
      .select(
        'tbl_book.book_ID',
        'tbl_book.book_Title',
        'tbl_book.book_PublisherName'
      )
      .groupBy('tbl_book.book_ID');

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

    res.render('home', {
      items: items,
      empty: items.length === 0,
      statsNXB: statsNXB,
      topBook: topBooks[0],
      searchKeyword: keyword
    });

  } catch (err) {
    console.error(err);
    res.status(500).send('Lỗi trong quá trình tìm kiếm!');
  }
});

app.listen(3000, function () {
  console.log('Server đang chạy tại: http://localhost:3000/homelb');
});