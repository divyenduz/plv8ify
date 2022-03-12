import React from 'react'
import ReactDOMServer from 'react-dom/server'

function Header({ children }) {
  return <h1>{children}</h1>
}

export function component(text: string) {
  return ReactDOMServer.renderToStaticMarkup(
    <div>
      <Header>Hello</Header> {text}
    </div>
  )
}
