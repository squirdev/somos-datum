import {Program} from "@project-serum/anchor";
import {programID} from "./config";
import {getCurrentState} from "./state";
import {getProvider} from "./util";
import idl from "./idl.json";

console.log(programID)

// provider
const provider = await getProvider()
console.log(provider)

// program
const program = new Program(idl, programID, provider);
console.log(program);
const account = await getCurrentState(program)
console.log(account)
