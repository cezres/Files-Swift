import styled from 'styled-components'

export const DocumentBrowserPanel = styled.div`
  display: flex;
  width: calc(100% - 40px);
  height: calc(100% - 40px);
  border-radius: 6px;
  box-shadow: 2px 2px 6px 0 #dfdfdf;
  background-color: #ffffff;
  padding: 20px;
  flex-direction: column;

  .title {
    width: 100%;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    .left {

    }
    .right {
      text-align: right;
    }
  }
  .header {
    background: rgb(243, 251, 255);
    margin-top: 10px;
    display: flex;
    flex-direction: row;
    height: 20px;
    padding-top: 10px;
    padding-bottom: 10px;
    .name {
      width: 60%;
    }
    .size {
      width: 20%;
    }
    .date {
      width: 20%;
    }
  }
  .table {
    overflow-y: scroll;

    .separation_line {
      height: 1px;
      background: rgb(242, 246, 253);
    }

    .cell {
      display: flex;
      flex-direction: row;
      height: 50px;

      .name {
        width: 60%;
        margin-top: 15px;
        height: 20px;
      }
      .size {
        width: 20%;
        margin-top: 15px;
        height: 20px;
      }
      .date {
        width: 20%;
        margin-top: 15px;
        height: 20px;
      }
    }
  }
`
