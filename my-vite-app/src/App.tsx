import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'

function App() {
  return (
    <>
      <div>
        <a href="https://vite.dev" target="_blank" rel="noreferrer">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank" rel="noreferrer">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>

      <h1>Kenyon Jared Mora Zamora</h1>
      <div className="card">
        <p><strong>Full-stack / DevOps-leaning Software Engineer</strong></p>
        <p>This site is deployed via a simple CI/CD pipeline:</p>
        <ul>
          <li>Vite + React</li>
          <li>GitHub Actions</li>
          <li>AWS EC2 (Amazon Linux)</li>
          <li>Nginx (static hosting)</li>
        </ul>

        <h2>About me</h2>
        <p>
          I build Next.js/React apps with Supabase backends, Stripe/Plaid integrations,
          and automate infrastructure with Terraform on AWS. I enjoy clean UI, strong validation,
          and production-ready pipelines.
        </p>

        <h2>Experience</h2>

        <h3>🚀 Junior Software Engineer Level 1 @ SAPIENCIA CONSULTORES SC</h3>
        <p><em>Jan 2025 – Jul 2025 · Remote · Querétaro, MX</em></p>
        <p>
          As a Junior Software Engineer Level 1 at Sapiencia Consultores, I contribute to both frontend and backend
          development, working as a full-stack developer. My role includes:
        </p>
        <ol>
          <li>Frontend with ReactJS and Angular: building reusable components and improving UI performance.</li>
          <li>Backend with NodeJS + Express: REST/GraphQL APIs, middleware, and scalable architecture.</li>
          <li>Writing modular, reusable TypeScript/JavaScript code following clean-code principles.</li>
          <li>Fixing bugs, optimizing SQL queries, and improving database efficiency using Prisma/Mongoose.</li>
          <li>Testing (Jest, React Testing Library, Mocha) and maintaining linting standards (ESLint/Prettier).</li>
          <li>Version control and code reviews with Git and GitHub.</li>
          <li>Implementing auth with JWT, OAuth, and Firebase Auth.</li>
          <li>CI/CD pipelines with GitHub Actions, AWS CodePipeline, and CodeDeploy.</li>
          <li>Collaborating with designers and documenting processes for maintainability.</li>
        </ol>

        <h4>Skills</h4>
        <ul>
          <li>JavaScript / TypeScript</li>
          <li>React.js / Angular</li>
          <li>Node.js / Express</li>
          <li>Amazon Web Services (AWS)</li>
          <li>Visual Basic for Applications (VBA)</li>
          <li>Git / GitHub</li>
        </ul>

        <hr />

        <h3>💼 Software Engineer @ Deloitte</h3>
        <p><em>Focus: Web Engineering & Cloud Computing</em></p>
        <ul>
          <li>Web Engineering</li>
          <li>Angular</li>
          <li>React.js</li>
          <li>Cloud Computing</li>
          <li>Explore Emerging Tech</li>
        </ul>
        <p>
          I collaborated in projects involving enterprise-level web applications using Angular and React.js,
          focusing on front-end performance, modularization, and cloud-native solutions.
        </p>

        <h4>Skills</h4>
        <ul>
          <li>Web Engineering</li>
          <li>Angular / React.js</li>
          <li>Cloud Computing</li>
          <li>AWS & Azure Fundamentals</li>
          <li>Team collaboration and agile practices</li>
        </ul>

        <h2>Highlights</h2>
        <ul>
          <li>SSA Disability Claims platform (Next.js + Supabase + MUI)</li>
          <li>Holcim consignment note ecosystem (Vue/NestJS/Flutter + AWS)</li>
          <li>SACSA traceability system (NestJS + Sequelize + Ant Design + Flutter)</li>
        </ul>

        <h2>Contact</h2>
        <ul>
          <li>GitHub: <a href="https://github.com/KenJaredMora" target="_blank" rel="noreferrer">KenJaredMora</a></li>
          <li>Email: <a href="mailto:kenyonnumero1@gmail.com">kenyonnumero1@gmail.com</a></li>
          <li>Location: Querétaro, MX</li>
        </ul>

        <p style={{ marginTop: 16 }}>
          <em>Every push to <code>main</code> builds and deploys automatically 🚀</em>
        </p>
      </div>
    </>
  )
}

export default App
