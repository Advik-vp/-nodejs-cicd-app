import { useState, useEffect, useRef } from 'react'
import './App.css' // We might not need this if we put everything in index.css but let's keep it clean
import './index.css' // Ensure our styles are applied

function App() {
  const [files, setFiles] = useState([])
  const [dragActive, setDragActive] = useState(false)
  const [message, setMessage] = useState('')
  const inputRef = useRef(null)

  const API_URL = '/api' // Use relative path for proxy support

  useEffect(() => {
    fetchFiles()
  }, [])

  const fetchFiles = async () => {
    try {
      const response = await fetch(`${API_URL}/files`)
      if (!response.ok) throw new Error('Failed to fetch files')
      const data = await response.json()
      setFiles(data.files || [])
    } catch (error) {
      console.error('Error fetching files:', error)
      setMessage('Failed to load files. Is the backend running?')
    }
  }

  const handleDrag = (e) => {
    e.preventDefault()
    e.stopPropagation()
    if (e.type === 'dragenter' || e.type === 'dragover') {
      setDragActive(true)
    } else if (e.type === 'dragleave') {
      setDragActive(false)
    }
  }

  const handleDrop = (e) => {
    e.preventDefault()
    e.stopPropagation()
    setDragActive(false)
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      handleFile(e.dataTransfer.files[0])
    }
  }

  const handleChange = (e) => {
    e.preventDefault()
    if (e.target.files && e.target.files[0]) {
      handleFile(e.target.files[0])
    }
  }

  const handleFile = async (file) => {
    const formData = new FormData()
    formData.append('file', file)

    setMessage(`Uploading ${file.name}...`)

    try {
      const response = await fetch(`${API_URL}/upload`, {
        method: 'POST',
        body: formData,
      })

      if (!response.ok) throw new Error('Upload failed')

      const result = await response.json()
      setMessage(`Successfully uploaded ${file.name}!`)
      fetchFiles() // Refresh list
    } catch (error) {
      console.error('Error uploading file:', error)
      setMessage('Upload failed. Please try again.')
    }
  }

  const onButtonClick = () => {
    inputRef.current.click()
  }

  return (
    <div className="app-container">
      <h1>Cloud Vault</h1>
      <p style={{ opacity: 0.7, marginBottom: '2rem' }}>Secure & Creative Local Storage</p>

      <div className="card">
        <div
          className={`file-drop-area ${dragActive ? 'drag-active' : ''}`}
          onDragEnter={handleDrag}
          onDragLeave={handleDrag}
          onDragOver={handleDrag}
          onDrop={handleDrop}
          onClick={onButtonClick}
        >
          <span className="file-msg">
            {dragActive ? 'Drop it like it\'s hot!' : 'Drag & Drop files here or click to upload'}
          </span>
          <input
            ref={inputRef}
            className="file-input"
            type="file"
            onChange={handleChange}
            title="Upload a file"
          />
        </div>
        {message && <p style={{ marginTop: '1rem', color: '#a5b4fc' }}>{message}</p>}
      </div>

      <div className="uploaded-files">
        {files.length === 0 ? (
          <p style={{ gridColumn: '1/-1', opacity: 0.5 }}>No files uploaded yet.</p>
        ) : (
          files.map((file, index) => (
            <div key={index} className="file-item">
              <span className="file-icon">📄</span>
              <a href={file.url} target="_blank" rel="noopener noreferrer" className="file-name">
                {file.name}
              </a>
            </div>
          ))
        )}
      </div>
    </div>
  )
}

export default App
