const {
  Alert,
  Button,
  Col,
  Container,
  Form,
  InputGroup,
  Nav,
  NavItem,
  Row,
  Table,
  Modal,
} = ReactBootstrap

class DataTypeSelector extends React.Component {
  render() {
    return (
      <Form.Select onChange={(e) => this.props.onChange(e.target.value)}>
        <option>Select...</option>
        {this.props.options.map((el) => (
          <optgroup label={el.group}>
            {el.items.map((option) => (
              <option value={option.type} selected={option.type === this.props.value}>{option.name}</option>
            ))}
          </optgroup>
        ))}
      </Form.Select>
    )
  }
}

class ColumnName extends React.Component {
  render() {
    return (
      <Form.Control name="columnName" value={this.props.value} onChange={(e) => this.props.onChange(e.target.value)} />
    )
  }
}

class ColumnsEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      columns: props.columns || [{
        name: '',
        type: ''
      }],
      addRows: 1,
      locale: ''
    };

    this.addRow = this.addRow.bind(this)
    this.deleteRow = this.deleteRow.bind(this)
    this.updateRow = this.updateRow.bind(this)
  }

  componentDidMount() {
    this.props.onColumnsChange(this.state.columns)
  }

  deleteRow(ind) {
    const columns = this.state.columns
    if (ind < 0) {
      columns.splice(0)
      columns.push({})
    } else {
      columns.splice(ind, 1)
    }
    this.setState({ columns })
    this.props.onColumnsChange(this.state.columns)
  }

  addRow(e) {
    const columns = this.state.columns
    let addRows = this.state.addRows
    while (addRows--) {
      columns.push({
        name: '',
        type: ''
      })
    }
    this.setState({ columns })
    this.props.onColumnsChange(this.state.columns)
  }

  updateRow(ind, data) {
    const columns = this.state.columns
    columns[ind] = {
      ...columns[ind],
      ...data
    }
    this.setState({ columns })
    this.props.onColumnsChange(this.state.columns)
  }

  render() {
    return (
      <>
        <Row>
          <Table striped bordered hover size="sm">
            <colgroup>
              <col style={{ width: '3em' }} />
              <col style={{ width: 'auto' }} />
              <col style={{ width: 'auto' }} />
              {/* <col style={{ width: 'auto' }} /> */}
              <col style={{ width: '3em' }} />
            </colgroup>
            <thead>
              <tr>
                <th>{this.state.columns.length}</th>
                <th>Datatype</th>
                <th>Column Name</th>
                {/* <th>Options</th> */}
                <th className="align-middle"><i class='btn far fa-trash-alt' onClick={() => this.deleteRow(-1)} /></th>
              </tr>
            </thead>
            <tbody>
              {this.state.columns.map((row, ind) => (
                <tr>
                  <td className="align-middle">{ind + 1}</td>
                  <td><DataTypeSelector options={this.props.datatypes} value={row['type']} onChange={(type) => this.updateRow(ind, { type })} /></td>
                  <td><ColumnName value={row['name']} onChange={(name) => this.updateRow(ind, { name })} /></td>
                  {/* <td></td> */}
                  <td className="align-middle"><i class='btn far fa-trash-alt' onClick={() => this.deleteRow(ind)} /></td>
                </tr>
              ))}
            </tbody>
          </Table>
        </Row>
        <Row>
          <Col sm={4} xl={2} xxl={3}>
            <InputGroup>
              <InputGroup.Text>Add</InputGroup.Text>
              <Form.Control type="number"
                min={1}
                value={this.state.addRows}
                onChange={(e) => { this.setState({ addRows: e.target.value }) }}
              />
              <Button variant="primary" onClick={this.addRow}>Rows</Button>
            </InputGroup>
          </Col>
        </Row>
      </>
    )
  }
}

class PreviewData extends React.Component {
  render() {
    if (!this.props.data.columns || !this.props.data.columns.length) {
      return <></>
    }
    return (
      <Table striped bordered hover variant="dark">
        <thead>
          {
            this.props.data.columns.map(column => (
              <th>{column.name}</th>
            ))
          }
        </thead>
        <tbody>
          {
            this.props.data.items.map(row => (
              <tr>{
                this.props.data.columns.map(column => (
                  <td>{row.hasOwnProperty(column.name) ? row[column.name].toString() : ''}</td>
                ))
              }</tr>
            ))
          }
        </tbody>
      </Table>
    )
  }
}

class GenerateModal extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      rows: 100,
      className: "dc.community.GeneratedData",
      createClass: true,
    }
  }
  render() {
    return <Modal
      {...this.props}
      size="lg"
      aria-labelledby="contained-modal-title-vcenter"
      centered
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-vcenter">
          Generate
        </Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <Form.Group as={Row} className="mb-3">
          <Form.Label column sm={2}>Rows</Form.Label>
          <Col sm={3}>
            <Form.Control
              type="number"
              value={this.state.rows}
              min={1}
              step={100}
              onChange={(e) => { this.setState({ rows: parseInt(e.target.value, 10) }) }}
            />
          </Col>
        </Form.Group>
        <Form.Group as={Row} className="mb-3">
          <Form.Label column sm={2}>Class name</Form.Label>
          <Col>
            <Form.Control
              value={this.state.className}
              onChange={(e) => { this.setState({ className: e.target.value }) }} />
          </Col>
        </Form.Group>
        <Form.Group as={Row} className="mb-3">
          <Form.Label column sm={2}>Create class</Form.Label>
          <Col>
            <Form.Check
              type="checkbox"
              checked={this.state.createClass}
              onChange={(e) => { this.setState({ createClass: e.target.checked }) }} />
          </Col>
        </Form.Group>
        {this.props.error ? <Alert variant="danger">{this.props.error}</Alert> : <></>}
        {this.props.info ? <Alert variant="success">{this.props.info}</Alert> : <></>}
      </Modal.Body>
      <Modal.Footer>
        <Button variant="outline-secondary" onClick={(e) => this.props.onHide(e)}>Cancel</Button>
        <Button onClick={(e) => this.props.onHide(e, this.state)}>Generate</Button>
      </Modal.Footer>
    </Modal>
  }
}

class Generator extends React.Component {
  constructor(props) {
    super(props);
    const columns = localStorage.hasOwnProperty('columns') ? JSON.parse(localStorage.getItem('columns')) : [{}]
    const locale = localStorage.hasOwnProperty('locale') ? localStorage.getItem('locale') : 'en_US'
    const previewRows = localStorage.hasOwnProperty('previewRows') ? localStorage.getItem('previewRows') : 5
    this.state = {
      columns,
      locale,
      previewRows,
      locales: [],
      datatypes: [],
      preview: {},
      fatalError: null,
      showModal: false,
      generateError: null,
      generateInfo: null,
    };

    this.update = this.update.bind(this)
    this.updatePreview = this.updatePreview.bind(this)
    this.updateLocales = this.updateLocales.bind(this)
    this.updateDatatypes = this.updateDatatypes.bind(this)
    this.generate = this.generate.bind(this)
  }

  updateLocales() {
    fetch("api/locale")
      .then(response => response.json())
      .then((locales) => {
        this.setState({ locales })
      })
  }

  updateDatatypes() {
    fetch("api/datatype")
      .then(response => response.json())
      .then((datatypes) => {
        this.setState({ datatypes })
      })
  }

  componentDidMount() {
    fetch("api/")
      .then(response => response.json())
      .then((response) => {
        if (response.status !== "OK") {
          this.setState({ fatalError: response.status })
        } else {
          this.updateLocales()
          this.updateDatatypes()
        }
      })
  }

  skipEmpty(object) {
    const values = Object.values(object)
    return values.length && !values.includes('')
  }

  updatePreview() {
    const { columns: allColumns, locale, previewRows } = this.state
    const columns = allColumns.filter(this.skipEmpty)
    if (!columns || !columns.length) {
      this.setState({ preview: {} })
      return
    }
    fetch("api/preview", {
      method: 'POST',
      body: JSON.stringify({
        previewRows: parseInt(previewRows, 10),
        locale,
        columns
      })
    })
      .then(response => response.json())
      .then((preview) => {
        this.setState({ preview })
      })
  }

  async update(data) {
    await this.setState(data)
    if (data.columns) { localStorage.setItem('columns', JSON.stringify(data.columns)) }
    if (data.locale) { localStorage.setItem('locale', data.locale) }
    if (data.previewRows) { localStorage.setItem('previewRows', parseInt(data.previewRows, 10)) }
    this.updatePreview()
  }

  generate(e, data) {
    this.setState({ generateError: null })
    this.setState({ generateInfo: null })
    if (!data) {
      this.setState({ showModal: false })
      return
    }
    const { columns: allColumns, locale } = this.state
    const columns = allColumns.filter(this.skipEmpty)
    if (!columns || !columns.length) {
      this.setState({ generateError: 'Nothing to generate, no columns' })
      return
    }
    const { rows, className, createClass } = data
    if (!className) {
      this.setState({ generateError: 'Please enter the ClassName' })
      return
    }
    fetch("api/generate", {
      method: 'POST',
      body: JSON.stringify({
        rows,
        className,
        createClass,
        locale,
        columns,
      })
    }).then(async response => {
      let json = {}
      try {
        json = await response.json()
      } catch {
        return Promise.reject("Unexpected response from server")
      }
      if (response.status >= 400) {
        return Promise.reject(json.status)
      }
      let created = json.created
      if (rows > created) {
        return Promise.reject(`Only ${created} items was created`)
      }

      this.setState({ generateInfo: "All looks good" })
    })
      .catch(error => {
        this.setState({ generateError: error })
      })
  }

  render() {
    return (
      <>
        <Container fluid className="min-vh-100 p-0">
          <Container fluid fixed="top" className="pt-5 pb-5 overflow-auto" style={{ height: '50vh' }}>
            <Container>
              <div class="text-center mt-5">
                <h2>InterSystems IRIS data generator with <a href="https://pypi.org/project/Faker/" target="_blank">Python Faker</a>
                </h2>
              </div>
              <ColumnsEditor datatypes={this.state.datatypes} columns={this.state.columns} onColumnsChange={(columns) => this.update({ columns })} />
            </Container>
          </Container>
          <Container fluid fixed="bottom" className="p-3 pb-5 bg-opacity-50 bg-success border-dark border-top overflow-auto" style={{ height: '50vh' }}>
            {/* <pre>{JSON.stringify({ locale: this.state.locale, columns: this.state.columns.filter(this.skipEmpty) }, null, 2)}</pre> */}
            <PreviewData data={this.state.preview}></PreviewData>
          </Container>
        </Container>
        <nav class="navbar fixed-bottom navbar-expand-lg navbar-dark bg-dark">
          <Container>
            <Row className="w-100">
              <Col sm={3} lg={2} className="px-1">
                <InputGroup>
                  <InputGroup.Text>Locale</InputGroup.Text>
                  <Form.Select onChange={(e) => this.update({ locale: e.target.value })}>
                    {
                      this.state.locales.map(locale => (
                        <option value={locale} selected={this.state.locale === locale}>{locale}</option>
                      ))
                    }
                  </Form.Select>
                </InputGroup>
              </Col>
              <Col sm={2} lg={2} className="px-1">
                <InputGroup>
                  <InputGroup.Text>Rows</InputGroup.Text>
                  <Form.Control
                    type="number"
                    min={1}
                    value={this.state.previewRows}
                    onChange={(e) => { this.update({ previewRows: e.target.value }) }}
                  />
                </InputGroup>
              </Col>
              <Col >
                <InputGroup>
                  <Button variant="secondary" onClick={() => this.updatePreview()}>Refresh</Button>
                </InputGroup>
              </Col>
              <Col>
                <InputGroup className="justify-content-end">
                  <Button onClick={(e) => { this.setState({ showModal: true }) }}>Generate</Button>
                </InputGroup>
              </Col>
            </Row>
          </Container>
        </nav>
        <GenerateModal error={this.state.generateError} info={this.state.generateInfo} show={this.state.showModal} onHide={this.generate}></GenerateModal>
        <Modal show={this.state.fatalError} keyboard={false} animation={false}>
        <Modal.Header className="alert-danger">
          <Modal.Title>Error</Modal.Title>
        </Modal.Header>
          <Modal.Body>
          {this.state.fatalError}
          </Modal.Body>
        </Modal>
      </>
    )
  }
}

ReactDOM.render(
  <Generator />,
  document.getElementById('root')
);
