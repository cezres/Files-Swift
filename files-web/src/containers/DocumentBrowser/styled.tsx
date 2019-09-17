import styled from 'styled-components'

export const DocumentBrowserPanel = styled.div`
  display: flex;
  margin: 0px 0px 0px 0px;
  width: 100vw;
  height: 100vh;
  background: rgb(247, 247, 247);

  .content {
    display: flex;
    width: calc(100% - 80px);
    height: calc(100% - 80px);
    margin: 40px 40px 40px 40px;
    border-radius: 6px;
    box-shadow: 2px 2px 6px 0 #dfdfdf;
    background-color: #ffffff;
    padding: 20px;
    flex-direction: column;

    .upload {
      background: rgb(73, 169, 248);
      width: 90px;
      height: 35px;
      margin-bottom: 20px;
      border-radius: 6px;
      cursor: pointer;
      .text {
        margin-top: 7px;
        margin-bottom: 8px;
        height: 20px;
        color: white;
        text-align: center;
      }
      &:hover {
        background: rgb(0, 153, 229);
      }
      >input {
        display: none;
      }
    }

    .title {
      width: 100%;
      display: flex;
      flex-direction: row;
      justify-content: space-between;
      font-size: 12px;
      color: rgb(140, 140, 140);
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
      height: 40px;
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
      margin-bottom: 0px;

      .separation_line {
        height: 1px;
        background: rgb(242, 246, 253);
      }

      .cell {
        display: flex;
        flex-direction: row;
        height: 50px;
        cursor: pointer;

        &:hover {
          background: rgb(243, 251, 255);
        }

        .icon {
          width: 40px;
          height: 50px;
          > img {
            margin-top: 10px;
            width: 30px;
            height: 30px;
          }
        }
        .name {
          width: calc(60% - 80px);
          margin-top: 15px;
          height: 20px;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
          padding-right: 40px;
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
  }
`
